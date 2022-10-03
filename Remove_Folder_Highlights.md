## I prefer not having any highlights on folders in my ls/ll commands since I can see the folder icons using lsd already

```shell
dircolors -p | sed 's/;42/;01/' > ~/.dircolors
source ~/.bashrc
```
