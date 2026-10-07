class MavenAT363 < Formula
  desc "Java-based project management"
  homepage "https://maven.apache.org/"
  url "https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz"
  sha256 "26ad91d751b3a9a53087aefa743f4e16a17741d3915b219cf74112bf87a438c5"

  keg_only :versioned_formula

  def install
    # Remove windows files
    rm_f Dir["bin/*.cmd"]

    # Fix the permissions on the global settings file.
    chmod 0644, "conf/settings.xml"

    libexec.install Dir["*"]

    # Link mvn, mvnDebug and mvnyjp. m2.conf stays in libexec/bin, where mvn
    # finds it after resolving its own symlink. Java is found the same way as a
    # manual install: JAVA_HOME, or a JDK registered with /usr/libexec/java_home.
    bin.install_symlink (Dir["#{libexec}/bin/*"] - ["#{libexec}/bin/m2.conf"])
  end

  def caveats
    mvn = HOMEBREW_PREFIX/"bin/mvn"
    owner = begin
      if mvn.symlink? && mvn.realpath.to_s.start_with?("#{HOMEBREW_CELLAR}/")
        mvn.realpath.relative_path_from(HOMEBREW_CELLAR).each_filename.first
      end
    rescue Errno::ENOENT
      nil
    end

    link_note = if linked?
      <<~EOS.chomp
        #{name} is now active.

        To switch to a different version, unlink this one first:
          brew unlink #{name}
      EOS
    elsif owner
      <<~EOS.chomp
        A different version is currently active.

        To switch to this version:
          brew unlink #{owner} && brew link #{name}
      EOS
    elsif mvn.exist? || mvn.symlink?
      <<~EOS.chomp
        #{mvn} exists but is not managed by Homebrew (or is a broken link).
        Remove or rename it, then:
          brew link #{name}
      EOS
    else
      <<~EOS.chomp
        No version of maven is currently active.

        To activate this version, link it into #{HOMEBREW_PREFIX}/bin:
          brew link #{name}
      EOS
    end

    <<~EOS
      #{link_note}

      Maven 3.6.3 requires Java 7 or newer, which this formula does not install.

      To see which JDKs macOS knows about:
        /usr/libexec/java_home -V
    EOS
  end
end
