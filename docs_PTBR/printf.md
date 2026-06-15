# printf(3) - Manual do Linux

## Nome

printf, fprintf, dprintf, sprintf, snprintf, vprintf, vfprintf, vdprintf, vsprintf, vsnprintf - conversão de saída formatada

## Sinopse

```c
#include <stdio.h>

int printf(const char *format, ...);
int fprintf(FILE *stream, const char *format, ...);
int dprintf(int fd, const char *format, ...);
int sprintf(char *str, const char *format, ...);
int snprintf(char *str, size_t size, const char *format, ...);

#include <stdarg.h>

int vprintf(const char *format, va_list ap);
int vfprintf(FILE *stream, const char *format, va_list ap);
int vdprintf(int fd, const char *format, va_list ap);
int vsprintf(char *str, const char *format, va_list ap);
int vsnprintf(char *str, size_t size, const char *format, va_list ap);
```

### Requisitos de Macro de Teste de Características para glibc

**snprintf(), vsnprintf():**
- `_XOPEN_SOURCE >= 500` ou `_ISOC99_SOURCE` ou
- `/* Versões glibc <= 2.19: */ _BSD_SOURCE`

**dprintf(), vdprintf():**
- Desde glibc 2.10: `_POSIX_C_SOURCE >= 200809L`
- Antes de glibc 2.10: `_GNU_SOURCE`

## Descrição

As funções da família printf() produzem saída de acordo com um formato conforme descrito abaixo:

- **printf()** e **vprintf()** escrevem a saída para stdout (fluxo de saída padrão)
- **fprintf()** e **vfprintf()** escrevem a saída para o fluxo de saída fornecido
- **sprintf()**, **snprintf()**, **vsprintf()** e **vsnprintf()** escrevem para a string de caracteres `str`
- **dprintf()** funciona como **fprintf()**, mas envia saída para um descritor de arquivo `fd` em vez de um fluxo stdio

As funções **snprintf()** e **vsnprintf()** escrevem no máximo `size` bytes (incluindo o byte nulo de terminação '\0') em `str`.

As funções **vprintf()**, **vfprintf()**, **vdprintf()**, **vsprintf()** e **vsnprintf()** são equivalentes às funções **printf()**, **fprintf()**, **dprintf()**, **sprintf()** e **snprintf()**, respectivamente, exceto que são chamadas com uma `va_list` em vez de um número variável de argumentos. Essas funções não chamam a macro `va_end`. Como invocam a macro `va_arg`, o valor de `ap` fica indefinido após a chamada. Consulte stdarg(3).

Todas essas funções escrevem a saída sob o controle de uma string de formato que especifica como argumentos subsequentes (ou argumentos acessados via facilidades de argumento de comprimento variável de stdarg(3)) são convertidos para saída.

### Observação Importante sobre Sobreposição

C99 e POSIX.1-2001 especificam que os resultados são indefinidos se uma chamada a **sprintf()**, **snprintf()**, **vsprintf()** ou **vsnprintf()** causasse cópia entre objetos que se sobrepõem (por exemplo, se a string de destino e um dos argumentos de entrada fornecidos referem-se ao mesmo buffer). Consulte a seção NOTAS.

## Formato da String de Formato

A string de formato é uma string de caracteres, começando e terminando em seu estado de mudança inicial, se houver. A string de formato é composta de zero ou mais diretivas:

- **Caracteres ordinários** (não %) que são copiados inalterados para o fluxo de saída
- **Especificações de conversão** que resultam em buscar zero ou mais argumentos subsequentes

Cada especificação de conversão é introduzida pelo caractere `%` e termina com um especificador de conversão. Entre eles pode haver (nesta ordem):

- Zero ou mais flags
- Um campo de largura mínima opcional
- Uma precisão opcional
- Um modificador de comprimento opcional

### Argumentos Posicionais

Os argumentos devem corresponder corretamente (após promoção de tipo) com o especificador de conversão. Por padrão, os argumentos são usados na ordem fornecida, onde cada `*` (veja campo de largura e precisão abaixo) e cada especificador de conversão solicita o próximo argumento (e é um erro se argumentos insuficientes forem fornecidos).

Você pode também especificar explicitamente qual argumento é tomado em cada lugar onde um argumento é necessário, escrevendo `"%m$"` em vez de `%` e `"*m$"` em vez de `*`, onde o inteiro decimal m denota a posição na lista de argumentos do argumento desejado, indexado começando de 1.

Por exemplo:
```c
printf("%*d", width, num);
printf("%2$*1$d", width, num);
```

Essas duas linhas são equivalentes. O segundo estilo permite referências repetidas ao mesmo argumento.

O padrão C99 não inclui o estilo usando `$`, que vem da Especificação UNIX Única. Se o estilo usando `$` for usado, deve ser usado em todos os conversores que tomam um argumento e todos os argumentos de largura e precisão, mas pode ser misturado com formatos `%%`, que não consomem um argumento.

Não pode haver lacunas nos números de argumentos especificados usando `$`; por exemplo, se argumentos 1 e 3 são especificados, o argumento 2 também deve ser especificado em algum lugar na string de formato.

### Caracteres de Raiz e Agrupamento

Para algumas conversões numéricas, um caractere de raiz ("ponto decimal") ou caractere de agrupamento de milhares é usado. O caractere real usado depende da parte LC_NUMERIC da localidade. (Consulte setlocale(3).)

A localidade POSIX usa '.' como caractere de raiz e não tem caractere de agrupamento. Por exemplo:

```c
printf("%'.2f", 1234567.89);
```

Resulta em "1234567.89" na localidade POSIX, em "1234567,89" na localidade nl_NL e em "1.234.567,89" na localidade da_DK.

## Caracteres de Flag

O caractere % é seguido por zero ou mais das seguintes flags:

### `#` - Forma Alternativa

O valor deve ser convertido para uma "forma alternada":

- Para conversões `o`: o primeiro caractere da string de saída é feito zero (prefixando um 0 se ainda não era zero)
- Para conversões `x` e `X`: um resultado diferente de zero tem a string "0x" (ou "0X" para conversões X) prefixada a ele
- Para conversões `a`, `A`, `e`, `E`, `f`, `F`, `g` e `G`: o resultado sempre conterá um ponto decimal, mesmo que nenhum dígito o siga
- Para conversões `g` e `G`: zeros à direita não são removidos do resultado como seriam de outra forma
- Para outras conversões, o resultado é indefinido

### `0` - Preenchimento com Zero

O valor deve ser preenchido com zero. Para conversões `d`, `i`, `o`, `u`, `x`, `X`, `a`, `A`, `e`, `E`, `f`, `F`, `g` e `G`, o valor convertido é preenchido à esquerda com zeros em vez de espaços.

- Se as flags `0` e `-` aparecerem, a flag `0` é ignorada
- Se uma precisão é fornecida com uma conversão numérica (`d`, `i`, `o`, `u`, `x` e `X`), a flag `0` é ignorada
- Para outras conversões, o comportamento é indefinido

### `-` - Justificação à Esquerda

O valor convertido fica alinhado à esquerda no limite do campo. (O padrão é justificação à direita.) O valor convertido é preenchido à direita com espaços, em vez de à esquerda com espaços ou zeros. Um `-` substitui um `0` se ambos forem dados.

### ` ` (espaço) - Espaço para Positivos

Um espaço em branco deve ser deixado antes de um número positivo (ou string vazia) produzido por uma conversão assinada.

### `+` - Sempre Mostrar Sinal

Um sinal (+ ou -) deve sempre ser colocado antes de um número produzido por uma conversão assinada. Por padrão, um sinal é usado apenas para números negativos. Um `+` substitui um espaço se ambos forem usados.

### `'` (apóstrofo) - Agrupamento de Milhares

Para conversão decimal (`i`, `d`, `u`, `f`, `F`, `g`, `G`), a saída é agrupada com caracteres de agrupamento de milhares se as informações de localidade indicarem. (Consulte setlocale(3).)

Nota: muitas versões de gcc(1) não conseguem analisar esta opção e emitirão um aviso. (SUSv2 não incluiu %'F, mas SUSv3 adicionou.)

### `I` - Dígitos Alternativos da Localidade

Para conversão de inteiro decimal (`i`, `d`, `u`), a saída usa os dígitos de saída alternativos da localidade, se houver. Por exemplo, desde glibc 2.2.3, isso fornecerá dígitos árabe-índicos na localidade persa ("fa_IR").

## Largura de Campo

Uma string de dígito decimal opcional (com primeiro dígito diferente de zero) especificando uma largura de campo mínima. Se o valor convertido tiver menos caracteres que a largura do campo, será preenchido com espaços à esquerda (ou à direita, se a flag de alinhamento à esquerda tiver sido fornecida).

Em vez de uma string de dígito decimal, você pode escrever `*` ou `*m$` (para algum inteiro decimal m) para especificar que a largura do campo é fornecida no próximo argumento, ou no m-ésimo argumento, respectivamente, que deve ser do tipo int.

Uma largura de campo negativa é interpretada como uma flag `-` seguida por uma largura de campo positiva. Em nenhum caso uma largura de campo inexistente ou pequena causa truncamento de um campo; se o resultado de uma conversão for mais amplo que a largura do campo, o campo é expandido para conter o resultado da conversão.

## Precisão

Uma precisão opcional, na forma de um período ('`.`') seguido por uma string de dígito decimal opcional. Em vez de uma string de dígito decimal, você pode escrever `*` ou `*m$` (para algum inteiro decimal m) para especificar que a precisão é fornecida no próximo argumento, ou no m-ésimo argumento, respectivamente, que deve ser do tipo int.

Se a precisão é fornecida como apenas '`.`', a precisão é considerada como zero. Uma precisão negativa é considerada como se a precisão fosse omitida.

A precisão especifica:
- O número mínimo de dígitos a aparecer para conversões `d`, `i`, `o`, `u`, `x` e `X`
- O número de dígitos a aparecer após o caractere de raiz para conversões `a`, `A`, `e`, `E`, `f` e `F`
- O número máximo de dígitos significativos para conversões `g` e `G`
- O número máximo de caracteres a serem impressos de uma string para conversões `s` e `S`

## Modificador de Comprimento

Aqui, "conversão de inteiro" significa conversão `d`, `i`, `o`, `u`, `x` ou `X`.

| Modificador | Descrição |
|---|---|
| `hh` | Uma conversão de inteiro subsequente corresponde a um argumento `signed char` ou `unsigned char`, ou uma conversão `n` subsequente corresponde a um ponteiro para um argumento `signed char`. |
| `h` | Uma conversão de inteiro subsequente corresponde a um argumento `short` ou `unsigned short`, ou uma conversão `n` subsequente corresponde a um ponteiro para um argumento `short`. |
| `l` (ell) | Uma conversão de inteiro subsequente corresponde a um argumento `long` ou `unsigned long`, ou uma conversão `n` subsequente corresponde a um ponteiro para um argumento `long`, ou uma conversão `c` subsequente corresponde a um argumento `wint_t`, ou uma conversão `s` subsequente corresponde a um ponteiro para um argumento `wchar_t`. |
| `ll` (ell-ell) | Uma conversão de inteiro subsequente corresponde a um argumento `long long` ou `unsigned long long`, ou uma conversão `n` subsequente corresponde a um ponteiro para um argumento `long long`. |
| `q` | Sinônimo para `ll`. Esta é uma extensão não padrão, derivada de BSD; evite seu uso em novo código. |
| `L` | Uma conversão subsequente `a`, `A`, `e`, `E`, `f`, `F`, `g` ou `G` corresponde a um argumento `long double`. (C99 permite %LF, mas SUSv2 não.) |
| `j` | Uma conversão de inteiro subsequente corresponde a um argumento `intmax_t` ou `uintmax_t`, ou uma conversão `n` subsequente corresponde a um ponteiro para um argumento `intmax_t`. |
| `z` | Uma conversão de inteiro subsequente corresponde a um argumento `size_t` ou `ssize_t`, ou uma conversão `n` subsequente corresponde a um ponteiro para um argumento `size_t`. |
| `Z` | Sinônimo não padrão para `z` que antecede o aparecimento de `z`. Não use em novo código. |
| `t` | Uma conversão de inteiro subsequente corresponde a um argumento `ptrdiff_t`, ou uma conversão `n` subsequente corresponde a um ponteiro para um argumento `ptrdiff_t`. |

SUSv3 especifica todos os anteriores, exceto pelos modificadores explicitamente observados como sendo extensões não padrão. SUSv2 especificou apenas os modificadores de comprimento `h` (em hd, hi, ho, hx, hX, hn) e `l` (em ld, li, lo, lx, lX, ln, lc, ls) e `L` (em Le, LE, Lf, Lg, LG).

Como uma extensão não padrão, as implementações GNU tratam `ll` e `L` como sinônimos, para que você possa, por exemplo, escrever `llg` (como sinônimo para o padrão `Lg`) e `Ld` (como sinônimo para o `lld` em conformidade com padrões). Tal uso não é portável.

## Especificadores de Conversão

Um caractere que especifica o tipo de conversão a ser aplicado. Os especificadores de conversão e seus significados são:

### `d`, `i` - Inteiro Decimal Assinado

O argumento int é convertido para notação decimal assinada. A precisão, se houver, fornece o número mínimo de dígitos que devem aparecer; se o valor convertido requer menos dígitos, é preenchido à esquerda com zeros. A precisão padrão é 1. Quando 0 é impresso com uma precisão explícita 0, a saída está vazia.

### `o`, `u`, `x`, `X` - Octal, Decimal e Hexadecimal Não Assinados

O argumento unsigned int é convertido para:
- `o` - Notação octal não assinada
- `u` - Notação decimal não assinada
- `x` e `X` - Notação hexadecimal não assinada

As letras abcdef são usadas para conversões `x`; as letras ABCDEF são usadas para conversões `X`. A precisão, se houver, fornece o número mínimo de dígitos que devem aparecer; se o valor convertido requer menos dígitos, é preenchido à esquerda com zeros. A precisão padrão é 1. Quando 0 é impresso com uma precisão explícita 0, a saída está vazia.

### `e`, `E` - Notação Exponencial

O argumento double é arredondado e convertido no estilo `[-]d.ddde±dd` onde há um dígito (que é diferente de zero se o argumento for diferente de zero) antes do caractere de ponto decimal e o número de dígitos após ele é igual à precisão; se a precisão estiver faltando, é considerada como 6; se a precisão for zero, nenhum caractere de ponto decimal aparece.

Uma conversão `E` usa a letra `E` (em vez de e) para introduzir o expoente. O expoente sempre contém pelo menos dois dígitos; se o valor for zero, o expoente é 00.

### `f`, `F` - Notação Decimal Fixa

O argumento double é arredondado e convertido para notação decimal no estilo `[-]ddd.ddd`, onde o número de dígitos após o caractere de ponto decimal é igual à especificação de precisão. Se a precisão estiver faltando, é considerada como 6; se a precisão for explicitamente zero, nenhum caractere de ponto decimal aparece. Se um ponto decimal aparecer, pelo menos um dígito aparece antes dele.

(SUSv2 não conhece F e diz que representações de string de caracteres para infinito e NaN podem estar disponíveis. SUSv3 adiciona uma especificação para F. O padrão C99 especifica "[-]inf" ou "[-]infinity" para infinito, e uma string começando com "nan" para NaN, no caso de conversão f, e "[-]INF" ou "[-]INFINITY" ou "NAN" no caso de conversão F.)

### `g`, `G` - Notação Geral

O argumento double é convertido no estilo f ou e (ou F ou E para conversões G). A precisão especifica o número de dígitos significativos. Se a precisão estiver faltando, 6 dígitos são fornecidos; se a precisão for zero, é tratada como 1.

O estilo e é usado se o expoente de sua conversão for menor que -4 ou maior ou igual à precisão. Zeros à direita são removidos da parte fracionária do resultado; um ponto decimal aparece apenas se seguido por pelo menos um dígito.

### `a`, `A` - Notação Hexadecimal Flutuante

(C99; não em SUSv2, mas adicionado em SUSv3) Para conversão `a`, o argumento double é convertido para notação hexadecimal (usando as letras abcdef) no estilo `[-]0xh.hhhhp±d`; para conversão `A`, o prefixo 0X, as letras ABCDEF e o separador de expoente P é usado.

Há um dígito hexadecimal antes do ponto decimal, e o número de dígitos após ele é igual à precisão. A precisão padrão é suficiente para uma representação exata do valor se uma representação exata em base 2 existe e é suficientemente grande para distinguir valores do tipo double. O dígito antes do ponto decimal é não especificado para números não normalizados e diferente de zero, mas de outra forma não especificado para números normalizados. O expoente sempre contém pelo menos um dígito; se o valor for zero, o expoente é 0.

### `c` - Caractere

Se nenhum modificador `l` estiver presente, o argumento int é convertido para um unsigned char e o caractere resultante é escrito. Se um modificador `l` estiver presente, o argumento `wint_t` (caractere largo) é convertido para uma sequência multibyte por uma chamada à função wcrtomb(3), com um estado de conversão começando no estado inicial, e a string multibyte resultante é escrita.

### `s` - String

**Sem modificador `l`:**
O argumento `const char *` é esperado ser um ponteiro para uma matriz de tipo de caractere (ponteiro para uma string). Caracteres da matriz são escritos até (mas não incluindo) um byte nulo de terminação ('\0'); se uma precisão é especificada, não mais que o número especificado são escritos. Se uma precisão é fornecida, nenhum byte nulo precisa estar presente; se a precisão não for especificada, ou for maior que o tamanho da matriz, a matriz deve conter um byte nulo de terminação.

**Com modificador `l`:**
O argumento `const wchar_t *` é esperado ser um ponteiro para uma matriz de caracteres largos. Caracteres largos da matriz são convertidos para caracteres multibyte (cada um por uma chamada à função wcrtomb(3), com um estado de conversão começando no estado inicial antes do primeiro caractere largo), até e incluindo um caractere largo nulo de terminação. Os caracteres multibyte resultantes são escritos até (mas não incluindo) o byte nulo de terminação.

Se uma precisão é especificada, não mais bytes que o número especificado são escritos, mas nenhum caractere multibyte parcial é escrito. Observe que a precisão determina o número de bytes escritos, não o número de caracteres largos ou posições de tela. A matriz deve conter um caractere largo nulo de terminação, a menos que uma precisão seja fornecida e seja tão pequena que o número de bytes escritos exceda isso antes do final da matriz ser atingido.

### `C` - Caractere Largo (não recomendado)

(Não em C99 ou C11, mas em SUSv2, SUSv3 e SUSv4.) Sinônimo para `lc`. Não use.

### `S` - String Larga (não recomendado)

(Não em C99 ou C11, mas em SUSv2, SUSv3 e SUSv4.) Sinônimo para `ls`. Não use.

### `p` - Ponteiro

O argumento ponteiro `void *` é impresso em hexadecimal (como se por `%#x` ou `%#lx`).

### `n` - Número de Caracteres Escritos

O número de caracteres escritos até agora é armazenado no inteiro apontado pelo argumento correspondente. Esse argumento deve ser um `int *`, ou variante cujo tamanho corresponda ao (opcionalmente) modificador de comprimento de inteiro fornecido. Nenhum argumento é convertido. (Este especificador não é suportado pela biblioteca C biônica.)

O comportamento é indefinido se a especificação de conversão incluir quaisquer flags, uma largura de campo ou uma precisão.

### `m` - Mensagem de Erro da Localidade

(Extensão Glibc; suportada por uClibc e musl.) Imprime saída de strerror(errno). Nenhum argumento é necessário.

### `%` - Caractere Percentual Literal

Um '%' é escrito. Nenhum argumento é convertido. A especificação de conversão completa é '%%'.

## Valor de Retorno

Após retorno bem-sucedido, essas funções retornam o número de caracteres impressos (excluindo o byte nulo usado para encerrar a saída em strings).

As funções **snprintf()** e **vsnprintf()** não escrevem mais que `size` bytes (incluindo o byte nulo de terminação '\0'). Se a saída foi truncada devido a esse limite, então o valor de retorno é o número de caracteres (excluindo o byte nulo de terminação) que teriam sido escritos na string final se espaço suficiente estivesse disponível. Assim, um valor de retorno de `size` ou mais significa que a saída foi truncada. (Veja também abaixo na seção NOTAS.)

Se um erro de saída for encontrado, um valor negativo é retornado.

## Atributos

Para uma explicação dos termos usados nesta seção, consulte attributes(7).

| Interface | Atributo | Valor |
|---|---|---|
| printf(), fprintf(), sprintf(), snprintf(), vprintf(), vfprintf(), vsprintf(), vsnprintf() | Segurança de thread | MT-Safe locale |

## Conformidade com Padrões

- **fprintf()**, **printf()**, **sprintf()**, **vprintf()**, **vfprintf()**, **vsprintf()**: POSIX.1-2001, POSIX.1-2008, C89, C99.
- **snprintf()**, **vsnprintf()**: POSIX.1-2001, POSIX.1-2008, C99.
- **dprintf()** e **vdprintf()**: Originalmente extensões GNU que foram posteriormente padronizadas em POSIX.1-2008.

### Notas sobre Valor de Retorno

Concernente ao valor de retorno de snprintf(), SUSv2 e C99 contradizem um ao outro: quando snprintf() é chamado com size=0, então SUSv2 estipula um valor de retorno não especificado menor que 1, enquanto C99 permite que str seja NULL neste caso, e fornece o valor de retorno (como sempre) como o número de caracteres que teriam sido escritos caso a string de saída tivesse sido suficientemente grande. POSIX.1-2001 e posterior alinham sua especificação de snprintf() com C99.

glibc 2.1 adiciona modificadores de comprimento hh, j, t, e z e caracteres de conversão a e A.

glibc 2.2 adiciona o caractere de conversão F com semântica C99, e o caractere de flag I.

## Notas

Alguns programas imprudentemente dependem de código tal como o seguinte:

```c
sprintf(buf, "%s some further text", buf);
```

para anexar texto a buf. Porém, os padrões explicitamente notam que os resultados são indefinidos se os buffers de origem e destino se sobrepõem ao chamar **sprintf()**, **snprintf()**, **vsprintf()** e **vsnprintf()**. Dependendo da versão de gcc(1) usada e das opções do compilador empregadas, chamadas como a acima não produzirão os resultados esperados.

A implementação glibc das funções **snprintf()** e **vsnprintf()** está em conformidade com o padrão C99, ou seja, se comporta conforme descrito acima, desde a versão glibc 2.1. Até glibc 2.0.6, eles retornariam -1 quando a saída fosse truncada.

## Problemas Conhecidos

Como **sprintf()** e **vsprintf()** assumem uma string arbitrariamente longa, os chamadores devem ter cuidado para não ultrapassar o espaço real; isso muitas vezes é impossível de assegurar. Observe que o comprimento das strings produzidas é dependente da localidade e difícil de prever. Use **snprintf()** e **vsnprintf()** em vez disso (ou asprintf(3) e vasprintf(3)).

Código tal como `printf(foo);` frequentemente indica um bug, já que foo pode conter um caractere `%`. Se foo vem de entrada de usuário não confiável, pode conter `%n`, causando que a chamada printf() escreva na memória e crie um buraco de segurança.

## Exemplos

### Imprimir Pi com Cinco Casas Decimais

```c
#include <math.h>
#include <stdio.h>

fprintf(stdout, "pi = %.5f\n", 4 * atan(1.0));
```

### Imprimir Data e Hora

Para imprimir uma data e hora na forma "Domingo, 3 de julho, 10:02", onde weekday e month são ponteiros para strings:

```c
#include <stdio.h>

fprintf(stdout, "%s, %s %d, %.2d:%.2d\n",
        weekday, month, day, hour, min);
```

### Impressão Internacionalizada

Muitos países usam a ordem dia-mês-ano. Portanto, uma versão internacionalizada deve ser capaz de imprimir os argumentos em uma ordem especificada pelo formato:

```c
#include <stdio.h>

fprintf(stdout, format,
        weekday, month, day, hour, min);
```

onde format depende da localidade e pode permutar os argumentos. Com o valor:

```
"%1$s, %3$d. %2$s, %4$d:%5$.2d\n"
```

você poderia obter "Domingo, 3. Julho, 10:02".

### Alocar String Suficientemente Grande

Para alocar uma string suficientemente grande e imprimir nela (código correto para glibc 2.0 e glibc 2.1):

```c
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

char *
make_message(const char *fmt, ...)
{
    int n = 0;
    size_t size = 0;
    char *p = NULL;
    va_list ap;

    /* Determinar tamanho necessário */

    va_start(ap, fmt);
    n = vsnprintf(p, size, fmt, ap);
    va_end(ap);

    if (n < 0)
        return NULL;

    /* Um byte extra para '\0' */

    size = (size_t) n + 1;
    p = malloc(size);
    if (p == NULL)
        return NULL;

    va_start(ap, fmt);
    n = vsnprintf(p, size, fmt, ap);
    va_end(ap);

    if (n < 0) {
        free(p);
        return NULL;
    }

    return p;
}
```

Se truncamento ocorre em versões glibc anteriores a 2.0.6, isso é tratado como um erro em vez de ser tratado graciosamente.

## Veja Também

- printf(1)
- asprintf(3)
- puts(3)
- scanf(3)
- setlocale(3)
- strfromd(3)
- wcrtomb(3)
- wprintf(3)
- locale(5)

## Informações Adicionais

Esta página é parte da versão 5.10 do projeto Linux man-pages. Uma descrição do projeto, informações sobre como relatar bugs e a versão mais recente desta página podem ser encontradas em: https://www.kernel.org/doc/man-pages/

---

**Versão GNU** - 2020-11-01
