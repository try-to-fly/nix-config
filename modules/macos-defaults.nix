{ username, ... }:

###################################################################################
#
#  Centralized macOS Defaults via nix-darwin's `system.defaults.*`
#
#  Common UX defaults are grouped here to keep them consistent and easy to manage.
#  Reference: nix-darwin manual (system.defaults.*)
#
###################################################################################
{
  system.defaults = {
    # Global app/system behaviors
    NSGlobalDomain = {
      # Show all filename extensions in Finder and open/save panels
      AppleShowAllExtensions = true;

      # Faster key repeat and initial delay (lower = faster)
      # Common values: KeyRepeat 1–2, InitialKeyRepeat ~15
      KeyRepeat = 2;
      InitialKeyRepeat = 15;

      # Disable press-and-hold to enable key repeat behavior
      ApplePressAndHoldEnabled = false;

      # Enable tap to click behavior (some setups also read this)
      "com.apple.mouse.tapBehavior" = 1; # 1 = tap-to-click enabled
    };

    # Dock configuration
    dock = {
      autohide = true;           # auto-hide dock
      "show-recents" = false;    # remove recent applications section
      minimize-to-application = true;
      mru-spaces = false;        # don’t auto-rearrange Spaces (optional but nice)
    };

    # Finder configuration
    finder = {
      ShowStatusBar = true;      # show status bar
      ShowPathbar = true;        # show path bar
      _FXShowPosixPathInTitle = true; # show full POSIX path in window title
    };

    # Screenshot configuration
    screencapture = {
      # Save screenshots to ~/Pictures/Screenshots
      location = "/Users/${username}/Pictures/Screenshots";
      # Disable window shadow in screenshots
      "disable-shadow" = true;
      # file type can be png, jpg, pdf, etc. (leave default png)
    };

    # Trackpad configuration
    trackpad = {
      Clicking = true;               # tap to click
      TrackpadThreeFingerDrag = true;# enable three-finger drag
    };
  };

  # Ensure screenshot directory exists
  system.activationScripts.ensureScreenshotDir.text = ''
    mkdir -p "/Users/${username}/Pictures/Screenshots"
  '';
}

