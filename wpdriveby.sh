# Clean-up
rm -f firstgrep.txt > /dev/null 2>&1
rm -f iplist.txt > /dev/null 2>&1
rm -f blocklist.txt > /dev/null 2>&1
clear

oneHourAgo=$(date --date '1 hour ago' +'%Y:%H')
now=$(date +'%Y:%H')
logDir="/home*/*/access-logs/*"

cat << "EOF"

  
 _ _ _ ___ _| |___|_|_ _ ___| |_ _ _ 
| | | | . | . |  _| | | | -_| . | | |
|_____|  _|___|_| |_|\_/|___|___|_  | v 2.0
      |_| "Hands off, hackers!" |___|	  


EOF

# Prompt user and grep logs accordingly
read -p $'Search for hits on:\n[W] wp-login.php\n[X] xmlrpc.php\n[Q] Quit\n> ' -n 1 answer
echo -e "\n"
if [[ $answer =~ ^[Ww]$ ]]; then
    echo -e "\nTrawling access-logs for wp-login.php..."
    grep wp-login.php $logDir | awk '{print $1}' | sort -n | uniq -c | sort -n | \
    tail -50 | awk '{if($1>100)print "Hits:",$1, "IP:",$2}' | tee -a "firstgrep.txt"
elif [[ $answer =~ ^[Xx]$ ]]; then
    echo -e "\nTrawling access-logs for xmlrpc.php hits..."
    grep ''$hourago'\|'$now'' $logDir | grep 'xmlrpc.php' | awk '{print $1}' | sort -n | \
    uniq -c | sort -n | tail -50 | awk '{if($1>100)print "Hits:",$1, "IP:",$2}' | tee -a "firstgrep.txt"
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
grep "Hits:" firstgrep.txt | awk '{print $4}' | tac | egrep -o '([0-9]+\.){3}[0-9]+' > iplist.txt

# add csf deny to IPs
while read line
do
    echo "csf -d $line" >> blocklist.txt
done < iplist.txt

# Block
echo "exit" >> blocklist.txt
chmod u+x blocklist.txt
sh blocklist.txt

# Clean-up
rm -f firstgrep.txt
rm -f iplist.txt
rm -f blocklist.txt

echo -e "\nAll Done"
