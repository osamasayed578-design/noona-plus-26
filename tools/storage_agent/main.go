// NOONA PLUS | وكيل التخزين المحلي لملفات الأرشيف
//
// برنامج صغير يثبت على جهاز أو خادم داخل الشركة ويحفظ ملفات الأرشيف على أقراصها. الوكيل هو من يتصل
// بالنظام (HTTPS صادر فقط) فلا يلزم فتح أي منفذ في شبكة الشركة.
//
//	noona-agent run        تشغيل في الواجهة (للتجربة)
//	noona-agent test       فحص الإعدادات والاتصال
//	noona-agent install    تثبيت كخدمة تعمل مع بدء الجهاز (Windows: مهمة مجدولة بحساب SYSTEM، Linux: systemd)
//	noona-agent uninstall  إزالة الخدمة
//	noona-agent version
//
// الإعدادات في noona-agent.json بجانب البرنامج: {"server": ".../ords/noona/agent/v1/", "key": "nsa_...", "path": "D:\\NoonaArchive"}
package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"time"
)

const version = "1.0.0"

type config struct {
	Server string `json:"server"`
	Key    string `json:"key"`
	Path   string `json:"path"`
	Poll   int    `json:"poll"` // ثواني بين طلبات المهام (الافتراضي 2)
}

type job struct {
	ID      int64  `json:"id"`
	Type    string `json:"type"`
	Content int64  `json:"content"`
	Ref     string `json:"ref"`
	Size    int64  `json:"size"`
	SHA256  string `json:"sha256"`
}

var (
	cfg     config
	client  = &http.Client{Timeout: 5 * time.Minute}
	lastErr string
	exeDir  string
)

func main() {
	exe, _ := os.Executable()
	exeDir = filepath.Dir(exe)
	cmd := "run"
	if len(os.Args) > 1 {
		cmd = os.Args[1]
	}
	switch cmd {
	case "version":
		fmt.Println("noona-agent", version, runtime.GOOS+"/"+runtime.GOARCH)
		return
	case "install":
		must(loadConfig())
		must(install(exe))
		return
	case "uninstall":
		must(uninstall())
		return
	}
	must(loadConfig())
	setupLog(cmd == "run")
	switch cmd {
	case "test":
		must(selfTest())
		fmt.Println("OK: الإعدادات صحيحة والاتصال بالنظام ناجح")
	case "run", "service":
		loop()
	default:
		fmt.Println("الأوامر: run | test | install | uninstall | version")
		os.Exit(2)
	}
}

func must(err error) {
	if err != nil {
		fmt.Fprintln(os.Stderr, "خطأ:", err)
		os.Exit(1)
	}
}

func loadConfig() error {
	f := filepath.Join(exeDir, "noona-agent.json")
	if v := os.Getenv("NOONA_AGENT_CONFIG"); v != "" {
		f = v
	}
	b, err := os.ReadFile(f)
	if err != nil {
		return fmt.Errorf("لا يوجد ملف الإعدادات %s: %w", f, err)
	}
	if err := json.Unmarshal(b, &cfg); err != nil {
		return fmt.Errorf("ملف الإعدادات غير صالح: %w", err)
	}
	cfg.Server = strings.TrimRight(strings.TrimSpace(cfg.Server), "/") + "/"
	if !strings.HasPrefix(cfg.Server, "http") || cfg.Key == "" || cfg.Path == "" {
		return errors.New("أكمل server وkey وpath في ملف الإعدادات")
	}
	if cfg.Poll <= 0 {
		cfg.Poll = 2
	}
	return os.MkdirAll(cfg.Path, 0o750)
}

// السجل في noona-agent.log بجانب البرنامج (يفرغ عند تجاوز 10MB)
func setupLog(console bool) {
	lf := filepath.Join(exeDir, "noona-agent.log")
	if st, err := os.Stat(lf); err == nil && st.Size() > 10<<20 {
		_ = os.Truncate(lf, 0)
	}
	f, err := os.OpenFile(lf, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o640)
	if err != nil {
		return
	}
	if console {
		log.SetOutput(io.MultiWriter(os.Stdout, f))
	} else {
		log.SetOutput(f)
	}
}

// ------------------------------------------------------------------ HTTP
func call(method, path string, body io.Reader, hdr map[string]string) ([]byte, int, error) {
	req, err := http.NewRequest(method, cfg.Server+path, body)
	if err != nil {
		return nil, 0, err
	}
	req.Header.Set("X-Agent-Key", cfg.Key)
	req.Header.Set("User-Agent", "noona-agent/"+version)
	for k, v := range hdr {
		req.Header.Set(k, v)
	}
	res, err := client.Do(req)
	if err != nil {
		return nil, 0, err
	}
	defer res.Body.Close()
	b, err := io.ReadAll(res.Body)
	if res.StatusCode >= 300 {
		var e struct {
			Error struct{ Code, Message string } `json:"error"`
		}
		if json.Unmarshal(b, &e) == nil && e.Error.Message != "" {
			return b, res.StatusCode, errors.New(e.Error.Message)
		}
		return b, res.StatusCode, fmt.Errorf("HTTP %d", res.StatusCode)
	}
	return b, res.StatusCode, err
}

func postJSON(path string, v any) error {
	b, _ := json.Marshal(v)
	_, _, err := call("POST", path, bytes.NewReader(b), map[string]string{"Content-Type": "application/json"})
	return err
}

// ------------------------------------------------------------------ الحلقة الرئيسية
func loop() {
	log.Printf("noona-agent %s: الحفظ في %s والنظام %s", version, cfg.Path, cfg.Server)
	var nextHello time.Time
	backoff := time.Duration(cfg.Poll) * time.Second
	for {
		if time.Now().After(nextHello) {
			if err := hello(); err != nil {
				log.Printf("تعذر الاتصال بالنظام: %v", err)
				time.Sleep(backoff)
				if backoff < time.Minute {
					backoff *= 2
				}
				continue
			}
			nextHello = time.Now().Add(time.Minute)
		}
		backoff = time.Duration(cfg.Poll) * time.Second
		n, err := work()
		if err != nil {
			log.Printf("المهام: %v", err)
			nextHello = time.Time{}
		}
		if n == 0 {
			time.Sleep(time.Duration(cfg.Poll) * time.Second)
		}
	}
}

func hello() error {
	files, size := usage()
	host, _ := os.Hostname()
	return postJSON("hello", map[string]any{"host": host, "version": version + " " + runtime.GOOS, "path": cfg.Path,
		"free": freeBytes(cfg.Path), "files": files, "bytes": size, "error": lastErr})
}

func usage() (n, size int64) {
	_ = filepath.WalkDir(cfg.Path, func(p string, d fs.DirEntry, err error) error {
		if err == nil && !d.IsDir() && !strings.HasPrefix(d.Name(), ".") {
			if i, e := d.Info(); e == nil {
				n++
				size += i.Size()
			}
		}
		return nil
	})
	return
}

func work() (int, error) {
	b, _, err := call("GET", "jobs", nil, nil)
	if err != nil {
		return 0, err
	}
	var r struct{ Jobs []job }
	if err := json.Unmarshal(b, &r); err != nil {
		return 0, err
	}
	for _, j := range r.Jobs {
		var res map[string]any
		var jerr error
		switch j.Type {
		case "PUT":
			res, jerr = doPut(j)
		case "GET", "RETURN":
			jerr = doGet(j)
		case "TEST":
			jerr = doTest()
		default:
			jerr = fmt.Errorf("مهمة غير معروفة %s", j.Type)
		}
		if (j.Type == "GET" || j.Type == "RETURN") && jerr == nil {
			if j.Type == "RETURN" {
				log.Printf("أعاد الملف %d إلى النظام (تبقى نسخته هنا حتى تحذفها)", j.Content)
			} else {
				log.Printf("أرسل الملف %d للعرض", j.Content)
			}
			continue // رفع الملف ينجز المهمة
		}
		if jerr != nil {
			lastErr = jerr.Error()
			log.Printf("المهمة %d (%s): %v", j.ID, j.Type, jerr)
			res = map[string]any{"ok": false, "error": jerr.Error()}
		} else {
			lastErr = ""
			log.Printf("المهمة %d (%s) تمت", j.ID, j.Type)
		}
		if err := postJSON(fmt.Sprintf("jobs/%d/done", j.ID), res); err != nil {
			log.Printf("إبلاغ نتيجة المهمة %d: %v", j.ID, err)
		}
	}
	return len(r.Jobs), nil
}

// مسار آمن داخل مجلد الحفظ فقط
func local(ref string) (string, error) {
	clean := filepath.Clean(filepath.FromSlash(ref))
	if ref == "" || filepath.IsAbs(clean) || strings.HasPrefix(clean, "..") {
		return "", fmt.Errorf("مسار غير صالح %q", ref)
	}
	return filepath.Join(cfg.Path, clean), nil
}

// حفظ ملف جديد: يكتب في ملف مؤقت ثم يعاد تسميته، والبصمة تحسب أثناء الكتابة
func doPut(j job) (map[string]any, error) {
	req, _ := http.NewRequest("GET", cfg.Server+fmt.Sprintf("file/%d", j.Content), nil)
	req.Header.Set("X-Agent-Key", cfg.Key)
	res, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		b, _ := io.ReadAll(res.Body)
		return nil, fmt.Errorf("تحميل الملف: HTTP %d %s", res.StatusCode, strings.TrimSpace(string(b)))
	}
	name := filepath.Base(j.Ref)
	if name == "." || name == "" || name == string(filepath.Separator) {
		name = fmt.Sprintf("file_%d.bin", j.Content)
	}
	ref := time.Now().Format("2006/01") + "/" + name
	dst, err := local(ref)
	if err != nil {
		return nil, err
	}
	if err := os.MkdirAll(filepath.Dir(dst), 0o750); err != nil {
		return nil, err
	}
	tmp := dst + ".part"
	f, err := os.Create(tmp)
	if err != nil {
		return nil, err
	}
	h := sha256.New()
	_, err = io.Copy(io.MultiWriter(f, h), res.Body)
	if cerr := f.Close(); err == nil {
		err = cerr
	}
	if err != nil {
		os.Remove(tmp)
		return nil, err
	}
	sum := hex.EncodeToString(h.Sum(nil))
	if j.SHA256 != "" && !strings.EqualFold(sum, j.SHA256) {
		os.Remove(tmp)
		return nil, errors.New("بصمة الملف المستلم لا تطابق الأصل")
	}
	if err := os.Rename(tmp, dst); err != nil {
		return nil, err
	}
	return map[string]any{"ok": true, "sha256": sum, "ref": ref}, nil
}

// إرسال ملف طُلب للعرض
func doGet(j job) error {
	p, err := local(j.Ref)
	if err != nil {
		return err
	}
	b, err := os.ReadFile(p)
	if err != nil {
		return fmt.Errorf("الملف غير موجود على جهاز الوكيل: %s", j.Ref)
	}
	_, _, err = call("POST", fmt.Sprintf("file/%d", j.Content), bytes.NewReader(b),
		map[string]string{"Content-Type": "application/octet-stream", "X-Job-Id": fmt.Sprint(j.ID)})
	return err
}

func doTest() error {
	p := filepath.Join(cfg.Path, ".noona_test")
	data := []byte("NOONA PLUS storage agent test " + time.Now().String())
	if err := os.WriteFile(p, data, 0o640); err != nil {
		return fmt.Errorf("تعذرت الكتابة في %s: %w", cfg.Path, err)
	}
	defer os.Remove(p)
	b, err := os.ReadFile(p)
	if err != nil || !bytes.Equal(b, data) {
		return fmt.Errorf("تعذرت القراءة من %s", cfg.Path)
	}
	return nil
}

func selfTest() error {
	if err := doTest(); err != nil {
		return err
	}
	return hello()
}

// ------------------------------------------------------------------ التثبيت كخدمة
func install(exe string) error {
	if runtime.GOOS == "windows" {
		// مهمة مجدولة بحساب SYSTEM عند بدء الجهاز، وتعاد كل دقيقة إن توقفت
		_ = exec.Command("schtasks", "/Delete", "/TN", "NoonaStorageAgent", "/F").Run()
		out, err := exec.Command("schtasks", "/Create", "/TN", "NoonaStorageAgent", "/TR", `"`+exe+`" service`,
			"/SC", "ONSTART", "/RU", "SYSTEM", "/RL", "HIGHEST", "/F").CombinedOutput()
		if err != nil {
			return fmt.Errorf("%v: %s (شغّل موجه الأوامر كمسؤول)", err, out)
		}
		_ = exec.Command("schtasks", "/Run", "/TN", "NoonaStorageAgent").Run()
		fmt.Println("تم التثبيت: مهمة NoonaStorageAgent تعمل الآن ومع كل تشغيل للجهاز")
		return nil
	}
	unit := fmt.Sprintf(`[Unit]
Description=NOONA PLUS storage agent
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=%s service
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
`, exe)
	if err := os.WriteFile("/etc/systemd/system/noona-agent.service", []byte(unit), 0o644); err != nil {
		return fmt.Errorf("%v (شغّل بـ sudo)", err)
	}
	for _, a := range [][]string{{"daemon-reload"}, {"enable", "--now", "noona-agent"}} {
		if out, err := exec.Command("systemctl", a...).CombinedOutput(); err != nil {
			return fmt.Errorf("systemctl %v: %v %s", a, err, out)
		}
	}
	fmt.Println("تم التثبيت: خدمة noona-agent تعمل الآن ومع كل تشغيل للجهاز")
	return nil
}

func uninstall() error {
	if runtime.GOOS == "windows" {
		_ = exec.Command("schtasks", "/End", "/TN", "NoonaStorageAgent").Run()
		out, err := exec.Command("schtasks", "/Delete", "/TN", "NoonaStorageAgent", "/F").CombinedOutput()
		if err != nil {
			return fmt.Errorf("%v: %s", err, out)
		}
		fmt.Println("تمت الإزالة (الملفات المحفوظة باقية في مكانها)")
		return nil
	}
	_ = exec.Command("systemctl", "disable", "--now", "noona-agent").Run()
	_ = os.Remove("/etc/systemd/system/noona-agent.service")
	_ = exec.Command("systemctl", "daemon-reload").Run()
	fmt.Println("تمت الإزالة (الملفات المحفوظة باقية في مكانها)")
	return nil
}
