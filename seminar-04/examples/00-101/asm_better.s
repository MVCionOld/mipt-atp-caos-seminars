   .text      // начало секции .text с кодом программы
   .global f  // указание о том, что метка f будет доступна извне (аналог extern в языке Си)

f:	// метка - имя функции или строки для перехода

    // Перед следующими инструкциями в регистрах лежат следующие значения:
    // x0 <- A, x1 <- B, x2 <- C, x3 <- x

    // smaddl X𝕕, W𝕒, W𝕓, X𝕔 <-> X𝕕 ← W𝕒 ∙ W𝕓 + X𝕔, где W𝕒 и W𝕓 - знаковые значения

    smaddl    x0, w0, w3, x1    // x0 <- A * x + B, x1 <- B, x2 <- C, x3 <- x
    smaddl    x0, w0, w3, x2    // x0 <- (A * x + B) * x + C, x1 <- B, x2 <- C, x3 <- x
    ret                         // возвращаемся из функции f
