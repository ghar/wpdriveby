clear
cat << "EOF"


 _ _ _ ___ _| |___|_|_ _ ___| |_ _ _
| | | | . | . |  _| | | | -_| . | | |
|_____|  _|___|_| |_|\_/|___|___|_  | v 2.0
      |_| "Hands off, hackers!" |___|


EOF

oneHourAgo=$(date --date '1 hour ago' +'%Y:%H')
now=$(date +'%Y:%H')
logDir="/home*/*/access-logs/*"

function cleanup() {
  rm -f firstgrep.txt > /dev/null 2>&1
  rm -f iplist.txt > /dev/null 2>&1
  rm -f blocklist.txt > /dev/null 2>&1
}

function wplogin_find() {
  echo -e "\nTrawling access-logs for wp-login.php..."
  grep wp-login.php $logDir | awk '{print $1}' | sort -n | uniq -c | sort -n | \
  tail -50 | awk '{if($1>100)print "Hits:",$1, "IP:",$2}' | tee -a "firstgrep.txt"
}

function xmlrpc_find()  {
  echo -e "\nTrawling access-logs for xmlrpc.php hits..."
  grep ''$hourago'\|'$now'' $logDir | grep 'xmlrpc.php' | awk '{print $1}' | sort -n | \
  uniq -c | sort -n | tail -50 | awk '{if($1>100)print "Hits:",$1, "IP:",$2}' | tee -a "firstgrep.txt"
}

function extract_ip {
 grep "Hits:" firstgrep.txt | awk '{print $4}' | tac | egrep -o '([0-9]+\.){3}[0-9]+' > iplist.txt
}

function add_csf() {
 while read line
 do
  echo "csf -d $line" >> blocklist.txt
 done < iplist.txt
}

function block() {
 echo "exit" >> blocklist.txt
 chmod u+x blocklist.txt
 sh blocklist.txt
}

cleanup

if [[ $1 =~ ^[-y]$ ]]; then
 wplogin_find
 xmlrpc_find 
 extract_ip
 add_csf
 echo -e "\nBlocking IPs"
 block
 echo -e "\nExited wpdriveby.sh"
 exit 1
fi

# Prompt user and grep logs accordingly
read -p $'Search for hits on:\n[W] wp-login.php\n[X] xmlrpc.php\n[Q] Quit\n> ' -n 1 answer
echo -e "\n"
if [[ $answer =~ ^[Ww]$ ]]; then
  wplogin_find
elif [[ $answer =~ ^[Xx]$ ]]; then
  xmlrpc_find
else
  echo -e "\nExited wpdriveby.sh"
  exit 1
fi

# Show user IPs and Hits total. Ask to deny. If not, remove firstgrep.txt and exit.
echo -e "\n"
read -p $'Continue and deny IP addresses?\n[Y] Yes\n[N] No\n> ' -n 1 -r
echo -e "\n"
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  rm -f firstgrep.txt
  echo -e "\nExited wpdriveby.sh"
  exit 1
fi

# extract IPs only
extract_ip

# add csf deny to IPs
add_csf

# Block
block

cleanup
echo -e "\nAll Done"
