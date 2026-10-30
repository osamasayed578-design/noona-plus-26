//go:build windows

package main

import (
	"syscall"
	"unsafe"
)

// المساحة الحرة على القرص الذي يحوي مجلد الحفظ
func freeBytes(path string) int64 {
	k := syscall.NewLazyDLL("kernel32.dll").NewProc("GetDiskFreeSpaceExW")
	p, err := syscall.UTF16PtrFromString(path)
	if err != nil {
		return -1
	}
	var free, total, totalFree uint64
	r, _, _ := k.Call(uintptr(unsafe.Pointer(p)), uintptr(unsafe.Pointer(&free)), uintptr(unsafe.Pointer(&total)), uintptr(unsafe.Pointer(&totalFree)))
	if r == 0 {
		return -1
	}
	return int64(free)
}
