#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 10/10/2021
# Data de atualização: 20/10/2021
# Versão: 0.06
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do OpenSSH Server v8.2.x
#
# OpenSSH (Open Secure Shell) é um conjunto de utilitários de rede relacionado à segurança que 
# provém a criptografia em sessões de comunicações em uma rede de computadores usando o protocolo 
# SSH. Foi criado com um código aberto alternativo ao código proprietário da suíte de softwares 
# Secure Shell, oferecido pela SSH Communications Security. OpenSSH foi desenvolvido como parte 
# do projeto OpenBSD.
#
# O TCP Wrapper é um sistema de rede ACL baseado em host, usado para filtrar acesso à rede a 
# servidores de protocolo de Internet (IP) em sistemas operacionais do tipo Unix, como Linux ou 
# BSD. Ele permite que o host, endereços IP de sub-rede, nomes e/ou respostas de consulta ident, 
# sejam usados como tokens sobre os quais realizam-se filtros para propósitos de controle de acesso.
#
# Monitoramento do Log do OpenSSH Server: tail -f /var/log/syslog | grep sshd
# Monitoramento das autenticações do OpenSSH Server: tail -f /var/log/auth.log | grep ssh
# Monitoramento das conexões permitidas do OpenSSH Server: tail -f /var/log/tcpwrappers-allow-ssh.log
# Monitoramento das conexões negadas do OpenSSH Server: tail -f /var/log/tcpwrappers-deny.log
#
# Site Oficial do Projeto OpenSSH: https://www.openssh.com/
# Site Oficial do Projeto OpenSSL: https://www.openssl.org/
#
# Arquivo de configuração dos parâmetros utilizados nesse script
source 00-parametros.sh
#
# Configuração da variável de Log utilizado nesse script
LOG=$LOGSCRIPT
#
# Verificando se o usuário é Root e se a Distribuição é >= 20.04.x 
# [ ] = teste de expressão, && = operador lógico AND, == comparação de string, exit 1 = A maioria 
# dos erros comuns na execução
clear
if [ "$USUARIO" == "0" ] && [ "$UBUNTU" == "20.04" ]
	then
		echo -e "O usuário é Root, continuando com o script..."
		echo -e "Distribuição é >= 20.04.x, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não é Root ($USUARIO) ou a Distribuição não é >= 20.04.x ($UBUNTU)"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
# Verificando todas as dependências do OpenSSH Server
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do OpenSSH Server, aguarde... "
	for name in openssh-server
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            exit 1; 
            }
		sleep 5
#
# Script de configuração do OpenSSH Server no GNU/Linux Ubuntu Server 20.04.x LTS
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Configuração do OpenSSH Server no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo OpenSSH Server.: TCP 22\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o Repositório Multiversão do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository multiverse &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando todo o sistema operacional, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
	apt -y dist-upgrade &>> $LOG
	apt -y full-upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo todos os software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
	apt -y autoclean &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando a Configuração do OpenSSH Server, aguarde...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do OpenSSH Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mv -v /etc/ssh/sshd_config /etc/ssh/sshd_config.old &>> $LOG
	cp -v conf/sshd_config /etc/ssh/sshd_config &>> $LOG
	cp -v conf/{hostname,hosts,hosts.allow,hosts.deny,issue.net,nsswitch.conf} /etc/ &>> $LOG
	cp -v $NETPLAN $NETPLAN.old &>> $LOG
	cp -v conf/00-installer-config.yaml $NETPLAN &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo $NETPLAN, pressione <Enter> para continuar.\n"
echo -e "CUIDADO!!!: o nome do arquivo de configuração da placa de rede pode mudar"
echo -e "dependendo da versão do Ubuntu Server, verifique o conteúdo do diretório:"
echo -e "/etc/netplan para saber o nome do arquivo de configuração do Netplan e altere"
echo -e "o valor da variável NETPLAN no arquivo de configuração: 00-parametros.sh"
	read
	vim $NETPLAN
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hostname, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/hostname
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hosts, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/hosts
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração nsswitch.conf, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/nsswitch.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração sshd_config, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando sshd: -t (text mode check configuration)
	read
	vim /etc/ssh/sshd_config
	sshd -t &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hosts.allow, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/hosts.allow
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hosts.deny, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/hosts.deny
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração issue.net, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/issue.net
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando os serviços do Netplan e do OpenSSH Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	netplan --debug apply &>> $LOG
	systemctl restart sshd &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do OpenSSH Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:22 -sTCP:LISTEN
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configuração do OpenSSH Server feita com Sucesso!!!."
	# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
	# opção do comando date: +%T (Time)
	HORAFINAL=$(date +%T)
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
read
exit 1