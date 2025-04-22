# Home Manager Configuration

This directory contains Home Manager configuration, organised using profiles and roles.

## Structure

- _profiles/_: Different system profiles (desktop, headless, etc.)
- _roles/_: Functional roles that can be applied (dev, email, messaging, etc.)
- _will/_: User-specific config

## Profiles

Profiles define system-type specific configurations:

- _desktop_: GUI applications and desktop environment integrations
- _headless: Core CLI tools for a headless server

## Roles

Roles define purpose-specific configurations:

- _dev_: Dev tools, languages, and LSPs etc.
- _email_: Email client and related tools
- _messaging_: Chat apps

## Usage

In `home.nix`, enable the profiles and roles wanted:

```nix
{
  # Enable profiles
  profiles.desktop.enable = true;

  # Enable roles
  roles = {
    dev = {
      enable = true;
      enableGo = true;
      enablePython = true;
    };
    email.enable = true;
  };
}
```

## Adding New Roles/Profiles

1. Create a new file in the appropriate directory
1. Define options and implementation
1. Add it to the default.nix import list in that directory

