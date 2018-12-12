# Localization

To add support for multiple languages in Project-Daissu, we use [i18n.lua](https://github.com/kikito/i18n.lua/tree/93f8cbef2aceb7df1163c3d96bd2f23702bb1164). To add a new string to the code, just add it to relevant file in this directory or create a new one (no need for setup).

For example, if I want to create a list of taunt strings, I will create `taunt.lua` on this directory and it will be like the following:

```lua
local pt, en = {}, {}

en['curse'] = "I don't like you."
pt['curse'] = "Seu pé-rapado do caralho."

return { en = en, pt = pt }
```

You can also just add it to an existing file if it is relevant for your string.

Now it is pretty simple to use it in Daissu:

```lua
local i18n = require "i18n"
-- ...
player:sendTaunt(i18n "taunt/curse")
```

We like to keep all languages for the given string next to each other, this way it is easier to spot errors and missing languages. Feel free to send a PR with your language.

**WARNING**: Don't store localized strings in variables to use (much) later. If you do, when languages are changed the stored string won't change.