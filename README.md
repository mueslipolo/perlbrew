# Perlbrew Dockerfile for offline install

- Based on centos8
- Uses Carton / cpanfile for Perl app libraires
- The Dockerfile is using multi-stages to keep images as small as possible
- Perl-5.34.0 aliased as 'current'

## Download required resources

    ./dl_res.sh

