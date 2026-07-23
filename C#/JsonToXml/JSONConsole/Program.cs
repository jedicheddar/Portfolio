using System.IO;
using System.Linq;

namespace JSONConsole
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Count() == 0)
            {
                return;
            }

            //first argument is the JSON file name
            string jsonFile = args[0];
            if (!File.Exists(jsonFile))
            {
                return;
            }

            //second argument is the XML file name
            string xmlFile = "";
            if (args.Count() > 1 && args[1] != "")
            {
                xmlFile = args[1];
            }
            else
            {
                if (jsonFile.LastIndexOf(".") > 0)
                {
                    string[] part = jsonFile.Split('.');
                    part[part.Count() - 1] = "xml";
                    xmlFile = string.Join(".", part);
                }
                else
                {
                    xmlFile = jsonFile + ".xml";
                }
            }

            //third argument is the root name
            string rootNode = "Root";
            if (args.Count() == 3)
            {
                rootNode = args[2];
            }

            //convert the JSON file to a XML string
            string xml = JsonToXml.JsonToXml.ConvertJson(File.ReadAllText(jsonFile), rootNode);

            //write to the new file
            if (!string.IsNullOrEmpty(xml))
            {
                using (StreamWriter sw = File.CreateText(xmlFile))
                {
                    sw.WriteLine(xml);
                }
            }
        }
    }
}
