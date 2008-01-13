# We include the modules via Object#send because Module#include is private.
#require 'model_auto_completer_helper.rb'  
#require 'model_auto_completer.rb'

ActionView::Base.send(:include, ModelAutoCompleterHelper)
ActionController::Base.send(:include, ModelAutoCompleter)
