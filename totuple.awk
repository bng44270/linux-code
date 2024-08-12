################################
# Parse out a two dimentional tuple from string value
#
# If Inner tuple has two values (key/value), the use
# of the Python dict class can be used to convert tuple
# into a dictionary
#
# Usage:
#
#     Set optional variable "is2d" to 1 to parse two-dimentional tuples 
#
# Example 1:
#
#     Input:    Chicago|Cincinnati|St. Louis|Washington, DC
#
#     Output:   ("Chicago","Cincinnati","St. Louis","Washington, DC")
#
# Example 2:
#
#     Input:    name,Bob|age,38|town,Chicago
#
#     Output:   (("name","Bob"),("age","38"),("town","Chicago"))
#
#     Output of dict:  { "name":"Bob", "age":"38", "town":"Chicago" }
#
################################

BEGIN {
	RS="|";
	printf("(");
}
{
	element = gensub(/"|\n/,"","g",$0);
	if (typeof(is2d) == "untyped") {
		printf("\"%s\",",element);
	}
	else {
		printf("(");
		c = split(element,a,",");
		for (i = 1; i <= c; i++) {
			printf("\"%s\",",a[i]);
		}
		printf("\b),",element);
	}
}
END {
	printf("\b)");
}