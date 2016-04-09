# wpdriveby
A bash script for cPanel server admins who experience loads spikes resulting from wp-login.php and/or xmlrpc.php attacks on Wordpress sites<br />

Script searches the /home*/all_users/access-logs/ path and adds deny into Config Server Firewall to reduce load.

<h3>Prequisites</h3>
- cPanel server
- Config Server Firewall (CSF) running on that server

<h3>How to</h3>
1. Place wpdriveby.sh into any directory 
2. Run "sh wpdriveby.sh" from within that directory
