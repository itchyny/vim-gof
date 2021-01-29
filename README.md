# vim-gof

![gof](https://user-images.githubusercontent.com/375258/74085564-6448fa00-4abd-11ea-8122-4786b75c9f78.gif)

## Usage
```
:Gof

" MRU using gof
:let g:gof_mru = 1
:Gof mru


" Exclude files by pattern from MRU
:let g:gof_mru_ignore_pattern = '\v/\.git/|/node_modules/'
```

### Requirements
- Vim with terminal feature (`exists('*term_start')`)
- [gof](https://github.com/mattn/gof)

## Author
itchyny (https://github.com/itchyny)

## License
This software is released under the MIT License, see LICENSE.
