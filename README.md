# cppinsights.nvim

Integrate [C++ Insights](https://cppinsights.io/) into your favourite editor using the [C++ Insights](https://cppinsights.io/)'s API.

<img src="https://user-images.githubusercontent.com/98312435/235350143-ed00ae6d-1525-4144-8df2-360a73813a6a.gif" />

## 📦 Installation

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup {
  {
    'v1nh1shungry/cppinsights.nvim',
    cmd = 'CppInsights',
  },
}
```

## ⚙️  Configuration

```lua
-- default
require('cppinsights').setup {
  standard = 'cpp17',
  alternative_styles = {
    ['alt-syntax-for'] = false,
    ['alt-syntax-subscription'] = false,
  },
  more_transformations = {
    ['all-implicit-casts'] = false,
    ['show-all-callexpr-template-parameters'] = false,
    ['use-libcpp'] = false,
    ['edu-show-initlist'] = false,
    ['edu-show-noexcept'] = false,
    ['edu-show-padding'] = false,
    ['edu-show-coroutines'] = false,
    ['edu-show-cfront'] = false,
    ['edu-show-lifetime'] = false,
  },
}
```

## 🚀 Usage

`CppInsights`: Send the content of the current buffer to [C++ Insights](https://cppinsights.io/), and put the result into a vertical split window if successful. Otherwise insert the diagnostics into the quickfix.
