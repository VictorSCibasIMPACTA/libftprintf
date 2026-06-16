# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: vicdos-s <vicdos-s@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/15 13:07:58 by vicdos-s          #+#    #+#              #
#    Updated: 2026/06/16 16:59:35 by vicdos-s         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME		= libftprintf.a

TEST_NAME	= test


CC			= cc
CFLAGS		= -Wall -Wextra -Werror

LIBFT_DIR	= ./libft
LIBFT		= $(LIBFT_DIR)/libft.a

SRCS_DIR	= ./srcs
SRCS		= $(SRCS_DIR)/main.c \
				$(SRCS_DIR)/handlers.c

OBJS		= $(SRCS:.c=.o)

INCLUDES	= -I $(LIBFT_DIR)

all: $(NAME)

$(NAME): $(OBJS) $(LIBFT)
		cp $(LIBFT) $(NAME)
		ar rcs $(NAME) $(OBJS)
		
$(LIBFT): FORCE
	make -C $(LIBFT_DIR)

%.o: %.c
		$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $OBJS
	make -C $(LIBFT_DIR) clean

fclean: clean
		rm -f $(NAME)
		make -C $(LIBFT_DIR) fclean

re: fclean all

teste: $(NAME)
	$(CC) $(CFLAGS) $(INCLUDES) $(TEST_SRC) $(NAME) -o $(TEST_NAME)
	@echo "\n Executável '$(TEST_NAME)' criado com sucesso!"
	@echo "Digite ./$(TEST_NAME) para rodar os testes.\n"
	./$(TEST_NAME)
	@find . -type f \( -name "*.o" -o -name "*.a" \) -delete

FORCE:

.PHONY: all clean fclean re teste