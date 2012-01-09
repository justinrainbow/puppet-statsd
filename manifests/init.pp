
class statsd (
	$graphite_host = "localhost",
	$graphite_user = "root",
	$graphite_port = 2003,
	$statsd_port   = 8125
) {

    exec { "download_statsd":
		command => "curl -L https://github.com/etsy/statsd/tarball/master | tar -zx -C /tmp",
		unless  => "test -d /usr/share/statsd"
	}

	exec { "install_statsd":
		command => "mv /tmp/etsy-statsd-* /usr/share/statsd",
		require => Exec["download_statsd"]
	}

	file { "/etc/statsd":
		ensure  => directory
	}

	file { "/etc/statsd/rdioConfig.js":
		content => template("statsd/statsd.conf.erb"),
		require => File["/etc/statsd"]
	}

	file { "/etc/init/statsd.conf":
		content => template("statsd/statsd.upstart.erb"),
		require => [
			File["/etc/statsd/rdioConfig.js"]
		]
	}

	service { "statsd":
		provider => "upstart",
    	enable   => true,
		require  => File["/etc/init/statsd.conf"]
	}
}
