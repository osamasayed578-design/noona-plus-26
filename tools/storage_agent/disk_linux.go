//go:build !windows

package main

import "syscall"

// المساحة الحرة على القرص الذي يحوي مجلد الحفظ
func freeBytes(path string) int64 {
	var st syscall.Statfs_t
	if err := syscall.Statfs(path, &st); err != nil {
		return -1
	}
	return int64(st.Bavail) * int64(st.Bsize)
}
