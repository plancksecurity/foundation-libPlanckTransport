# libpEpTransport (v1.0)

Interfacing between transports written in different programming languages

## Build dependencies
* YML 2.7.1

## Build Configuration

The build configuration file is called `local.conf`.
Use the file `local.conf.example` as a template.

```bash
cp local.conf.example local.conf
```

Then, tweak it to your needs.

## Make Targets

The default make target is `src`.

### Build
`make src` - Generates all the headers and source files

### Install
`make install` - Installs the header files in $PREFIX/include/pEp   
`make uninstall` - Removes all headers from $PREFIX/include/pEp 

### Clean
`make clean`


