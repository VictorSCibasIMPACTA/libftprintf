# va_start(3) - Manual do Linux

# NOME

`stdarg`, `va_start`, `va_arg`, `va_end`, `va_copy` - listas de argumentos variáveis

# SINTAXE

```c
#include <stdarg.h>

void va_start(va_list ap, last);
type va_arg(va_list ap, type);
void va_end(va_list ap);
void va_copy(va_list dest, va_list src);
```

# DESCRIÇÃO

Uma função pode ser chamada com um número variável de argumentos de tipos variados. O cabeçalho `<stdarg.h>` declara o tipo `va_list` e define três macros para percorrer uma lista de argumentos cujo número e tipos não são conhecidos pela função chamada.

A função chamada deve declarar um objeto do tipo `va_list` que será usado pelas macros `va_start()`, `va_arg()` e `va_end()`.

## va_start()

A macro `va_start()` inicializa `ap` para uso subsequente por `va_arg()` e `va_end()`, e deve ser chamada primeiro.

O argumento `last` é o nome do último argumento antes da lista de argumentos variáveis, ou seja, o último argumento cujo tipo a função chamadora conhece.

Como o endereço desse argumento pode ser usado na macro `va_start()`, ele não deve ser declarado como variável `register`, nem como função ou tipo array.

## va_arg()

A macro `va_arg()` expande para uma expressão que tem o tipo e o valor do próximo argumento na chamada. O argumento `ap` é o `va_list` inicializado por `va_start()`. Cada chamada a `va_arg()` modifica `ap` de modo que a próxima chamada retorne o próximo argumento. O argumento `type` é um nome de tipo especificado de forma que o tipo de um ponteiro para um objeto com o tipo especificado possa ser obtido simplesmente adicionando um `*` a `type`.

A primeira utilização de `va_arg()` após `va_start()` retorna o argumento depois de `last`. Invocações sucessivas retornam os valores dos argumentos restantes.

Se não houver próximo argumento, ou se `type` não for compatível com o tipo do argumento real (após as promoções padrão de argumentos), ocorrerão erros aleatórios.

Se `ap` for passado para uma função que use `va_arg(ap, type)`, então o valor de `ap` é indefinido após o retorno dessa função.

## va_end()

Cada invocação de `va_start()` deve ser casada com uma invocação correspondente de `va_end()` na mesma função. Após a chamada `va_end(ap)` a variável `ap` fica indefinida. É possível fazer múltiplas travessias da lista, cada uma envolvida por `va_start()` e `va_end()`. `va_end()` pode ser uma macro ou uma função.

## va_copy()

A macro `va_copy()` copia a lista de argumentos variáveis previamente inicializada `src` para `dest`. O comportamento é como se `va_start()` fosse aplicado a `dest` com o mesmo argumento `last`, seguido pelo mesmo número de invocações `va_arg()` que foram usadas para alcançar o estado atual de `src`.

Uma implementação óbvia teria um `va_list` como um ponteiro para a pilha do frame da função variádica. Nesse arranjo (de longe o mais comum) parece não haver problema em atribuir:

```c
va_list aq = ap;
```

Infelizmente, também existem sistemas que fazem de `va_list` um array de ponteiros (de comprimento 1), e aí é necessário:

```c
va_list aq;
*aq = *ap;
```

Finalmente, em sistemas onde argumentos são passados em registradores, pode ser necessário que `va_start()` aloque memória, armazene os argumentos lá e também uma indicação de qual argumento é o próximo, para que `va_arg()` possa percorrer a lista. Agora `va_end()` pode liberar a memória alocada. Para acomodar essa situação, o C99 adiciona a macro `va_copy()`, para que a atribuição acima possa ser substituída por:

```c
va_list aq;
va_copy(aq, ap);
...
va_end(aq);
```

Cada invocação de `va_copy()` deve ser casada com uma invocação correspondente de `va_end()` na mesma função. Alguns sistemas que não fornecem `va_copy()` têm `__va_copy` em vez disso, pois esse foi o nome usado na proposta inicial.

# ATRIBUTOS

Para uma explicação dos termos usados nesta seção, veja `attributes(7)`.

| Interface                 | Thread safety       | Valor            |
|--------------------------:|:-------------------:|:----------------:|
| `va_start()`, `va_end()`, | MT-Safe             |                  |
| `va_copy()`               |                     |                  |
| `va_arg()`                | MT-Safe race: ap    |                  |

# CONFORMIDADE

As macros `va_start()`, `va_arg()` e `va_end()` estão em conformidade com C89. O C99 define a macro `va_copy()`.

# BUGS

Ao contrário das históricas macros `varargs`, as macros `stdarg` não permitem que programadores codifiquem uma função sem argumentos fixos. Esse problema gera trabalho principalmente ao converter código `varargs` para `stdarg`, mas também cria dificuldades para funções variádicas que desejam repassar todos os seus argumentos para uma função que recebe um `va_list`, como `vfprintf(3)`.

# EXEMPLO

A função `foo` recebe uma string de caracteres de formato e imprime o argumento associado a cada caractere de formato com base no tipo.

```c
#include <stdio.h>
#include <stdarg.h>

void
foo(char *fmt, ...)   /* '...' é a sintaxe C para função variádica */
{
    va_list ap;
    int d;
    char c;
    char *s;

    va_start(ap, fmt);
    while (*fmt)
        switch (*fmt++) {
        case 's':              /* string */
            s = va_arg(ap, char *);
            printf("string %s\n", s);
            break;
        case 'd':              /* int */
            d = va_arg(ap, int);
            printf("int %d\n", d);
            break;
        case 'c':              /* char */
            /* precisa de cast aqui já que va_arg só aceita tipos totalmente promovidos */
            c = (char) va_arg(ap, int);
            printf("char %c\n", c);
            break;
        }
    va_end(ap);
}
```

# VEJA TAMBÉM

`vprintf(3)`, `vscanf(3)`, `vsyslog(3)`

# COLOFÃO

Esta página faz parte da release 5.10 do projeto man-pages do Linux. Uma descrição do projeto, informações sobre como reportar bugs e a versão mais recente desta página podem ser encontradas em https://www.kernel.org/doc/man-pages/.

2020-11-01 — STDARG(3)
