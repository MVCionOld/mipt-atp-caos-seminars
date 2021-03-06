   .text      // начало секции .text с кодом программы
   .global f  // указание о том, что метка f будет доступна извне (аналог extern в языке Си)
              
f:	// метка - имя функции или строки для перехода

    // Перед следующими инструкциями в регистрах лежат следующие значения:
    // x0 <- A, x1 <- B, x2 <- C, x3 <- x

    mul       x0, x0, x3    // x0 <- A * x, x1 <- B, x2 <- C, x3 <- x
    mul       x0, x0, x3    // x0 <- A * x * x, x1 <- B, x2 <- C, x3 <- x
    mul       x1, x1, x3    // x0 <- A * x * x, x1 <- B * x, x2 <- C, x3 <- x
    add       x0, x0, x1    // x0 <- A * x * x + B * x, x1 <- B * x, x2 <- C, x3 <- x
    add       x0, x0, x2    // x0 <- A * x * x + B * x + c, x1 <- B * x, x2 <- C, x3 <- x
    ret                     // возвращаемся из функции f
