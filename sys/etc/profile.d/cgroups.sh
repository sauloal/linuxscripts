#/etc/profiles.d/
if [ "$PS1" ] ; then
  mkdir -m 0700 /dev/cgroup/cpu/user/$$ 2>/dev/null
  echo $$ > /dev/cgroup/cpu/user/$$/tasks 2>/dev/null
fi

