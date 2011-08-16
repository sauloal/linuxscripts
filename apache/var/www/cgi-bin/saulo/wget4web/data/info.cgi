# Directory for Wget logs
#$logsdir = "/home/download/logs";
$logsdir = "/var/www/cgi-bin/service/wget4web/data/logs";

# Directory for tasks for wget
#$tasksdir = "/home/download/tasks";
$tasksdir = "/var/www/cgi-bin/service/wget4web/data/tasks";

# There save downloading files
$filesdir = "/home/download/files";
$filesdir = "/var/www/cgi-bin/service/wget4web/data/files";

# Perion of refresh statistic page (in second)
$refreshstat = 30;

# How many days keep Wget logs and show information from they
# in statistic page
$deletelogs = 5;

# Numbers of tries to download when generated errors 5xx or 4xx
$numbersoftry = 5;
