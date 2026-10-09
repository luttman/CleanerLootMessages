# Cleaner Loot Messages
The only purpose of this lightweight Addon is to reduce the loot messages to a minimum for a clearer information.
 

For example, your loot will be displayed as :
"+ [object_name]"

For a party member :
"+ [player_name] : [object_name]"

For a multiple craft of a party member :
"+ [player_name]: [object_name]x2 (craft)"

 

Work for group loot, craft, harvesting, reputation, XP ...

 

This addon is really light and has an extremely low impact on the game as it only redefine the way the message are formated.


![alt text](https://i.imgur.com/CJa6xrD.png)

## Current clients

| Client | Interface | Manifest |
| --- | --- | --- |
| Retail 12.1.0 | 120100 | `_Mainline.toc` |
| Fresh / TBC Anniversary 2.5.6 | 20506 | `_TBC.toc` |
| MoP Classic 5.5.4 | 50504 | `_Mists.toc` |
| Forever | 16001 | `_Camelot.toc` |
| Classic Era / Hardcore / Season of Discovery 1.15.9 | 11509 | `_Vanilla.toc` |

Retail, Anniversary, MoP and Era versions were checked against Blizzard's EU
version service on 2026-10-09. Forever uses the same Interface value as
[ThreeCrownsGuild](https://github.com/luttman/ThreeCrownsGuild).
Legacy Wrath, Cataclysm and 3.3.5 manifests remain for existing users; their
clients have not been tested in this update.

The addon supports both `ChatFrameUtil.AddMessageEventFilter` and the older
`ChatFrame_AddMessageEventFilter`. Missing strings and incompatible format
placeholders keep Blizzard's original text. Reordered localized placeholders
also keep the original text; shortened labels such as `craft` remain English.
Coin colors apply only to English text in money messages. Blizzard's coin
icons and other languages are left unchanged. Secret Retail messages are not
inspected or modified.

Automated tests use mocked WoW APIs. They do not replace testing in the game.
Before a release, enable `/console scriptErrors 1`, reload, and check self and
party loot, stack counts, crafting, money, currency, XP and reputation on each
client. On Retail, also test combat and `loadDeprecationFallbacks` disabled.
Check that item links still open and that there are no Lua or blocked-action
errors, including alongside other chat addons.

## Releases

GitHub Actions checks Lua 5.1 syntax, runs compatibility tests and builds and
checks the installable ZIP on pushes to `main`, pull requests and tag pushes.
Only a tag push publishes. Existing tags such as `1.0.26` and tags prefixed
with `v` are both supported.

The workflow uses the same [BigWigs packager](https://github.com/BigWigsMods/packager)
as ThreeCrownsGuild. It creates a GitHub release with a universal ZIP containing
the `CleanerLootMessages` folder, sets the version from the tag and includes
client metadata in `release.json`. Tests and workflows are excluded.

GitHub publication uses the automatically supplied `GITHUB_TOKEN`. To publish
to the existing CurseForge project `677974`, set the repository Actions secret
`CF_API_KEY`. To also publish to the existing Wago project `Xb6XOxNp`, set
`WAGO_API_TOKEN`. Never put upload tokens in source files. Missing upload
tokens skip the corresponding service; GitHub releases still work.

After merging the changes, publish a new version from the repository:

```sh
git pull --ff-only
git tag -a 1.0.27 -m "Release 1.0.27"
git push origin 1.0.27
```

Download the attached `CleanerLootMessages-<version>.zip`, extract it into
`Interface/AddOns`, and replace the old addon folder when upgrading. GitHub's
automatically generated source archives are not the installable release ZIP.

## Addon policy review

The code was reviewed against [Blizzard's addon development policy](https://eu.forums.blizzard.com/en/wow/t/wow-user-interface-add-on-development-policy/1642)
and [Midnight's addon restrictions](https://worldofwarcraft.blizzard.com/en-gb/news/24244638/how-midnights-upcoming-game-changes-will-impact-combat-addons).
No policy violations were found in the repository: the code is public and
readable, has no paid feature gate, ads, in-game donation requests or offensive
content, sends no chat or addon network traffic, and does not automate gameplay
or bypass protected APIs. It changes message presentation and leaves secret
messages untouched. Blizzard retains the right to disable addon functionality.

This is a source review, not Blizzard approval or proof of performance in a
running client. Changes to Blizzard's global message strings can conflict with
other chat addons that parse those strings. The repository has no explicit
license; choose one before granting others redistribution rights. A license
is separate from Blizzard's requirement that addon code be visible.
