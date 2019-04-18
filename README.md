# YAWG

Yet Another Website Generator. [Powers my personal site](https://shanti.wtf).

## Why?

I'm tired of using large, bloated website generators when all I want is a
really simple and stupid website generator of my own. This is my riff on the
Makefile-based static site generator.

## How?

I'm hosting this AND testing this locally using [h2o](h2o.yaml).

## Publishing

Publish the site with:
```
make publish
```

## Who?

Shanti Chellaram \[[github](https://github.com/shantiii)\].

## TODOs

- [x] Add dates to blog posts.
- [ ] Sort by those dates.
- [ ] Make formatting not terrible. (Also, define 'not-terrible')
- [ ] Support assets (like images).
- [ ] Add photography blog post.
- [ ] CAS storage for assets, so I can have multiple references to the same file end up getting elided into a single thing.
- [ ] Use webfonts?
- [ ] Conditional font compilation - compile fonts I can embed with only the font information required on the generated webpage.
