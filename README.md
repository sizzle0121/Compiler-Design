# Introduction to Compiler Design  
`Some simple projects for practicing compiler design`  
  
## [Project 1](https://github.com/sizzle0121/Compiler-Design/tree/master/project1)  
A scanner for P language.  
### Abilities:  
The scanner can analyze tokens in a P language program.  
If there is an unrecognized character in it, the scanner will output the error message, including the number of line and the bad character.  
The pseudocomment can control whether tokens should be listed and whether each line should be displayed.  

### Platform:  
Linux  
  
### How to run?  
First, use “makefile” to build the scanner.  
% make  
And then execute the scanner with the input file name.  
% ./scanner [input file name]  
  
### Learn:  
Use `LEX` to generate a scanner.  
Write regular expressions for P language.  

