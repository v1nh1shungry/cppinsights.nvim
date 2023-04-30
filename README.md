# cppinsights.nvim

Integrate [C++ Insights](https://cppinsights.io/) into your favourite editor using the [C++ Insights](https://cppinsights.io/)'s API.

# Installation

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup {
  {
    'v1nh1shungry/cppinsights.nvim',
    cmd = 'CppInsights',
    dependencies = 'nvim-lua/plenary.nvim',
  },
}
```

# Default Configuration

```lua
require('cppinsights').setup {
  standard = 'cpp17',
  alternative_styles = {
    ['alt-syntax-for'] = false,
    ['alt-syntax-subscription'] = false,
  },
  more_transformations = {
    ['all-implicit-casts'] = false,
    ['use-libcpp'] = false,
    ['edu-show-initlist'] = false,
    ['edu-show-noexcept'] = false,
    ['edu-show-padding'] = false,
    ['edu-show-coroutines'] = false,
  },
}
```

# Usage

`CppInsights`: Send the content of the current buffer to [C++ Insights](https://cppinsights.io/), and put the result into a vertical split window if successful. Otherwise insert the diagnostics into the quickfix.
