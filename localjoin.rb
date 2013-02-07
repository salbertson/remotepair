fork do
  sleep 1
  exec('chmod 777 /tmp/awesomeness')
end

exec('tmux -S /tmp/awesomeness')
