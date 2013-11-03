package model {
	
	import flash.net.SharedObject;
	
	public class UserSettings {
		
		static const SETTINGS_NAME:String = "difractor_configuration";
		
		public static function saveWorkingPath(path:String):void
		{
			var settings:SharedObject = SharedObject.getLocal(SETTINGS_NAME);
			settings.data.workingPath = path;
			settings.flush();
		}
		
		public static function loadWorkingPath():String
		{
			var settings:SharedObject = SharedObject.getLocal(SETTINGS_NAME);
			return settings.data.workingPath;
		}


	}
	
}
