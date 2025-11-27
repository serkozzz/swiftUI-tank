//
//  test.h
//  TankEngineXCFramework
//
//  Created by Sergey Kozlov on 26.11.2025.
//

#ifndef test_h
#define test_h

#ifdef __cplusplus
extern "C" {
#endif

// Простейшая тестовая функция: возвращает сумму двух чисел.
// Удобно вызывать из Swift как обычную функцию.
int testBridgeFunction(int a, int b);

// Тестовая функция, возвращающая ObjC-строку.
// В Swift придёт как String (автобридж через NSString).
const NSString * _Nonnull testBridgeString(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* test_h */
