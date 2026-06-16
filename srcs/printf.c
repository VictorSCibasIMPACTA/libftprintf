/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   printf.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: vicdos-s <vicdos-s@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/06/15 13:03:18 by vicdos-s          #+#    #+#             */
/*   Updated: 2026/06/16 18:25:13 by vicdos-s         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"
#include "libftprintf.h"

static int (* const handlers[256])(va_list *) = {
	['c'] = print_char,
};

int ft_printf(const char* format, ...)
{
 va_list	args;
 int		count;

 va_start(args, format);
 count = 0;
 while (*format)
 {
	if (*format == '%' && *(format+1))
	{
		format++;
		if ((handlers[(unsigned char)*format]))
		count += handlers[(unsigned char)*format](&args);
	}
	else
	count += write(1, format, 1);
	format++;	
 }
 va_end(args);
 return(count);
}
