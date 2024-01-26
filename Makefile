###########################
# checkfile
#
# Check a file path to verify that a executable exists
#
# Syntax:
#    $(call checkfile,/path/to/binary)
#
# Iterate through list of binaries (Note:  binarylist is a space delimited list of paths to executables
#    $(foreach thisbin,$(binarylist),$(call checkfile,$(thisbin)))
###########################
define checkfile
$(if $(shell which $(1)),,$(error "Binary not found: $(1)"))
endef


#################
# newsetting
#
# Writes a name/value pair to a defined text file.  This function pairs with the getsetting function.
#
# Syntax:
#   $(call newsetting,PROMPT-TEXT,SETTING-NAME,DEFAULT-VALUE,SETTING-FILE)
#
# Example:
#   $(call newsetting,Enter the binary path,BINPATH,/usr/local/bin,/tmp/settings)
#
# This will create the following user prompt:
#   Enter the binary path [/usr/local/bin]:
#
# The resulting file (/tmp/settings) if left with the default settings will look like this:
#   BINPATH /usr/local/bin
#################
define newsetting
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "$(2) $(3)" >> $(4) || echo "$(2) $$thisset" | sed 's/\/$$//g' >> $(4)
endef

#################
# getsetting
#
# Reads a value from a file based on the name.  This fucntion pairs with the newsetting function.
#
# Syntax:
#   $(call getsetting,SETTING-NAME,SETTING-FILE)
#
# Example:
#   $(call newsetting,BINPATH,/tmp/settings)
#################
define getsetting
$$(grep "^$(2)[ \t]*" $(1) | sed 's/^$(2)[ \t]*//g')
endef

#################
# newlist
#
# Defines a list and writes list to a specified file
#
# Syntax:
#   $(call newlist,/tmp/people)
#################
define newlist
@echo "Enter a blank line when finished"
@while true; do read -p "$(1): " thisval ; [[ -z "$$thisval" ]] && break ; echo "$$thisval" >> $(2) ; done
endef

#################
# m4define
#
# Defines an  m4 macro
#
# Syntax (single-line):
#   $(call m4define,TMPFOLDER,/tmp)" > test.m4
#
# Syntax (multi-line):
#   $(call m4define,FILEDATA,Line 1\nLine2\nLine 3)
#################
define m4define
@echo -e "define(\`$(1)',\`$(shell printf "$(2)" | sed -z 's/\n/\\n/g')')"
endef

##############
# Create a C Header file "#define" directive with a non-string value
#
# Usage:
#   $(call newdefine,Enter the number of files,FILE_COUNT,1,settings.h)
#
#   The above code will result in the following line if no number is entered:
#      #define FILE_COUNT 1
#
#   The above code will result in the following line if 4 is entered:
#      #define FILE_COUNT 4
##############
define newdefine
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "#define $(2) $(3)" >> $(4) || echo "#define $(2) $$thisset" | sed 's/\/$$//g' >> $(4)
endef

##############
# Create a C Header file "#define" directive with a string value
#
# Usage:
#   $(call newdefinestr,Enter the directory,FOLDER_PATH,/tmp,settings.h)
#
#   The above code will result in the following line if no number is entered:
#      #define FOLDER_PATH "/tmp"
#
#   The above code will result in the following line if "/usr/share" is entered:
#      #define FOLDER_PATH "/usr/share"
##############
define newdefinestr
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "#define $(2) \"$(3)\"" >> $(4) || echo "#define $(2) \"$$thisset\"" | sed 's/\/$$//g' >> $(4)
endef

##############
# Returns the value of a #define directive from a header file
#
# Usage:
#   $(call getdefine,settings.h,FOLDER_NAME)
#
#   The above code will return the value of #define FOLDER_NAME 
##############
define getdefine
$$((cpp -P <<< "$$(cat $(1) ; echo "$(2)")") | sed 's/"//g')
endef

##############
# Validate SSL Cert/Key pair
#
# Usage:
#   $(call certkeyval,/path/to/key_file,/path/to/cert_file)
#
#   If validation fails, the make process will abort and display a message accordingly
##############
define certkeyval
@(test -n "$(call getdefine,$(H_FILE),$(1))" && test -n "$(call getdefine,$(H_FILE),$(2))" && test -f $(call getdefine,$(H_FILE),$(1)) && test -f $(call getdefine,$(H_FILE),$(2)) && test "$$(openssl rsa -modulus -noout -in $(call getdefine,$(H_FILE),$(1)))" = "$$(openssl x509 -modulus -noout -in $(call getdefine,$(H_FILE),$(2)))" && echo "Verified cert/key pair") || (echo "Error verifying cert/key pair"; exit 1)
endef
