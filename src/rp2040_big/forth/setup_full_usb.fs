\ Copyright (c) 2021-2023 Travis Bemann
\
\ Permission is hereby granted, free of charge, to any person obtaining a copy
\ of this software and associated documentation files (the "Software"), to deal
\ in the Software without restriction, including without limitation the rights
\ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
\ copies of the Software, and to permit persons to whom the Software is
\ furnished to do so, subject to the following conditions:
\ 
\ The above copyright notice and this permission notice shall be included in
\ all copies or substantial portions of the Software.
\ 
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
\ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
\ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
\ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
\ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
\ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
\ SOFTWARE.

\ This is not actual Forth code, but rather setup directives for e4thcom to be
\ executed from the root of the zeptoforth directory to initialize zeptoforth
\ on an RP2040 device.

#include src/common/forth/basic.fs
#include src/common/forth/module.fs
#include src/common/forth/armv6m.fs
#include src/common/forth/fast_basic.fs
#include src/common/forth/minidict.fs
#include src/common/forth/value.fs
#include src/common/forth/interrupt.fs
#include src/common/forth/exception.fs
#include src/rp2040/forth/multicore.fs
#include src/rp2040/forth/erase.fs
#include src/common/forth/lambda.fs
#include src/common/forth/fixed.fs
#include src/common/forth/systick.fs
#include src/rp2040/forth/int_io.fs
#include src/rp2040/forth/gpio.fs
#include src/rp2040/forth/pin.fs
#include src/rp2040/forth/pio.fs
#include src/common/forth/task.fs
#include src/rp2040/forth/led.fs
#include src/common/forth/full_default.fs
#include src/rp2040/forth/timer.fs
#include src/rp2040/forth/rng.fs
#include src/rp2040_big/forth/qspi.fs
#include src/common/forth/block.fs
#include src/common/forth/edit.fs
#include src/rp2040/forth/dma.fs
#include src/rp2040/forth/dma_pool.fs
#include src/rp2040/forth/uart.fs
#include src/rp2040/forth/adc.fs
#include src/rp2040/forth/spi.fs
#include src/rp2040/forth/i2c.fs
#include src/rp2040/forth/pwm.fs
#include src/rp2040/forth/rtc.fs
#include src/common/forth/full_extra.fs
#include src/rp2040/forth/usb.fs
#include src/common/forth/save_minidict.fs

\ Set a cornerstone to enable deleting everything compiled after this code
cornerstone restore-state

mini-dict::save-flash-mini-dict
