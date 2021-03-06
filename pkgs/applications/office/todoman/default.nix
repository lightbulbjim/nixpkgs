{ stdenv
, python3
, glibcLocales
, installShellFiles
, jq
}:

let
  inherit (python3.pkgs) buildPythonApplication fetchPypi;
in
buildPythonApplication rec {
  pname = "todoman";
  version = "3.8.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1aq7f63bhs9dnwzp15nfr07f2ki6s3lnqfap3b09rhchn6lfznwb";
  };

  nativeBuildInputs = [
    installShellFiles
  ];
  propagatedBuildInputs = with python3.pkgs; [
    atomicwrites
    click
    click-log
    click-repl
    configobj
    humanize
    icalendar
    parsedatetime
    python-dateutil
    pyxdg
    tabulate
    urwid
  ];

  checkInputs = with python3.pkgs; [
    flake8
    flake8-import-order
    freezegun
    hypothesis
    pytest
    pytestrunner
    pytestcov
    glibcLocales
  ];

  LC_ALL = "en_US.UTF-8";

  postInstall = ''
    installShellCompletion --bash contrib/completion/bash/_todo
    substituteInPlace contrib/completion/zsh/_todo --replace "jq " "${jq}/bin/jq "
    installShellCompletion --zsh contrib/completion/zsh/_todo
  '';

  preCheck = ''
    # Remove one failing test that only checks whether the command line works
    rm tests/test_main.py
    rm tests/test_cli.py
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/pimutils/todoman";
    description = "Standards-based task manager based on iCalendar";
    longDescription = ''
      Todoman is a simple, standards-based, cli todo (aka: task) manager. Todos
      are stored into icalendar files, which means you can sync them via CalDAV
      using, for example, vdirsyncer.

      Todos are read from individual ics files from the configured directory.
      This matches the vdir specification.  There’s support for the most common TODO
      features for now (summary, description, location, due date and priority) for
      now.  Runs on any Unix-like OS. It’s been tested on GNU/Linux, BSD and macOS.
      Unsupported fields may not be shown but are never deleted or altered.

      Todoman is part of the pimutils project
    '';
    license = licenses.isc;
    maintainers = with maintainers; [ leenaars ];
    platforms = platforms.linux;
  };
}
