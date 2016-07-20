all:
	gem build xoxzo-cloudruby.gemspec

release:
	bundle exec rake release