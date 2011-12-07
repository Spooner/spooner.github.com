usage       'release project [options]'
aliases     :rel
summary     'Makes a release post'
description <<END
Creates a release post for a project version, optionally with tags.

    > nanoc release Alpha Channel -v 1.2.4
END

option :t, :tags, 'specify tags', :argument => :optional
option :v, :version, 'specify version', :argument => :required

run do |opts, args, cmd|
  if args.empty?
    puts "Release requires a project name"
    exit 0
  end

  tags = (opts[:tags] || "").downcase.split /[,;.]/
  underscored_project = args.map(&:strip).join("_").downcase
  version = opts[:version]

  now = Time.now
  base_dir = File.expand_path("../../", __FILE__) + "/"

  type = %w[games libraries utilities].find {|t| File.exists? "#{base_dir}content/#{t}/#{underscored_project}" }

  unless type
    puts "Project name not recognised: #{underscored_project}"
    exit 0
  end

  if version
    version = "v#{version}" unless version[0] == 'v'
  else
    puts "Version required to release #{underscored_project}"
    exit 0
  end

  File.read("#{base_dir}content/#{type}/#{underscored_project}.md") =~ /\ntitle: (.*)\n/
  project_title = $1

  release_file = "#{base_dir}content/#{type}/#{underscored_project}/releases/#{version.tr(".", "_")}.md"
  FileUtils.mkdir_p File.dirname(release_file)

  if File.exists? release_file
    puts "Release with that version already exists"
    exit 0
  end

  unless version =~ /^v\d+(?:\.\d+)+[a-z]*$/
    puts "Version must follow pattern v0[.0]+"
    exit 0
  end

  tags.unshift type[0..-2] unless tags.include? type[0..-2]
  tags.unshift underscored_project unless tags.include? underscored_project

  File.open(release_file, "w") do |file|
    file.puts <<END
---
title: #{project_title} #{version}
kind: article
layout: release
created_at: #{now}
tags: #{tags}
---

* empty release
END
  end

  puts "Released: #{release_file.sub(base_dir, '')}"

  releases_file = "#{File.dirname(release_file)}/index.md"

  unless File.exists? releases_file
    File.open(releases_file, "w") do |file|
      file.puts <<END
---
# Autogenerated - do not edit!
title: Releases
kind: article
layout: releases
count_comments: true
---

END
    end
  end

  puts "Created releases index: #{releases_file.sub(base_dir, '')}"
end