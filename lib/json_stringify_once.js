module.exports = function stringifyOnce(obj, replacer, indent){
    var printedObjects = [];
    var printedObjectKeys = [];

    function printOnceReplacer(key, value){
        var printedObjIndex = false;
        printedObjects.forEach(function(obj, index){
            if(obj===value){
                printedObjIndex = index;
            }
        });

        if(printedObjIndex && typeof(value)=="object"){
          var name = (value ? value.constructor.name : value || "[unknown]").toLowerCase();
            return "(see " + name + " with key " + printedObjectKeys[printedObjIndex] + ")";
        }else{
            var qualifiedKey = key || "(empty key)";
            printedObjects.push(value);
            printedObjectKeys.push(qualifiedKey);
            if(replacer){
                return replacer(key, value);
            }else{
                return value;
            }
        }
    }
    return JSON.stringify(obj, printOnceReplacer, indent);
};
