rpm -qa --queryformat "%{name}\n" | sort | uniq > installed_packages.log