#!/usr/bin/env ruby
require 'redis'

HOSTS = { :redis01 => "192.168.57.2",
          :redis02 => "192.168.57.3",
          :redis03 => "192.168.57.4"
}

SENTINELS = [{:host => HOSTS[:redis01], :port => 26379},
             {:host => HOSTS[:redis02], :port => 26379},
             {:host => HOSTS[:redis03], :port => 26379}]

#redis = Redis.new(:url => "redis://test", :password => "Beekeango8eph5Go8Uquahng2iegh7owe0eighieraeKeud1ZievouG9ohrahTh7", :sentinels => SENTINELS, :role => :master)
#redis.set("mykey", "hello world!")
#(0..1000000).each{|i|
#    begin
#        redis.set(i,i)
#        $stdout.write("SET (#{i} times)\n") if i % 100 == 0
#    rescue => e
#        $stdout.write("E")
#    end
#    #sleep(0.01)
#}

CONNECTIONS = HOSTS.inject({}) do |c, (k, v)|
  c[k] = Redis.new host: v, password: 'Beekeango8eph5Go8Uquahng2iegh7owe0eighieraeKeud1ZievouG9ohrahTh7'
  c
end

$sentinel = Redis.new host: HOSTS[:redis01], port: 26379

case ARGV[0].to_sym
when :setup
  CONNECTIONS[:redis01].slaveof "NO", "ONE"
  CONNECTIONS[:redis02].slaveof HOSTS[:redis01], 6379
  CONNECTIONS[:redis03].slaveof HOSTS[:redis01], 6379
when :failover
  $sentinel.sentinel :failover, :test
when :kill
  ip, port = $sentinel.client.call %w(sentinel get-master-addr-by-name test)
  p ip
  p port
  r = Redis.new host: ip, port: port
  r.client.call %w(debug segfault)
when :restore
  HOSTS.each do |k, v|
    %x[vagrant ssh #{k} -- sudo service redis start]
  end
when :status
  puts $sentinel.info['master0']
when :console
  exec("redis-cli -h #{HOSTS[ARGV[1].to_sym]}")
end
