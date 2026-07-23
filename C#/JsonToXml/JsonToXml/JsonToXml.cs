using Newtonsoft.Json;
using System;
using System.Xml.Linq;
using System.Linq;
using System.Collections.Generic;

namespace JsonToXml
{
    public class JsonToXml
    {
        /// <summary>
        /// This function converts Json string to XML
        /// </summary>
        /// <param name="json">Inout Json string</param>
        /// <returns>Converted XML string</returns>
        public static string ConvertJson(string json, string root)
        {
            XDocument doc = null;
            try
            {
                doc = JsonConvert.DeserializeXNode(json, root);
                if (root == "Root" || root == "Compass")
                    doc = AddPrefix(doc);
            }
            catch (Exception e)
            {
                string ex = e.Message;
                ex = ex + Environment.NewLine + e.StackTrace;
                return ex;
            }
            return doc.ToString();
        }

        public static XDocument AddPrefix(XDocument doc)
        {
            XElement root = doc.Root;
            // first, get the list of all parent nodes and put into namespaces
            List<XNamespace> list = new List<XNamespace>();
            foreach (XElement element in root.Descendants().Where(x => !x.HasElements))
            {
                XNamespace ns = "https://www.alliantnational.com/" + element.Parent.Name.LocalName;
                if (!list.Contains(ns))
                {
                    root.SetAttributeValue(XNamespace.Xmlns + element.Parent.Name.LocalName, ns);
                    list.Add(ns);
                }
                // second, add the prefix to the node
                element.Name = ns + element.Name.LocalName;
            }
            return doc;
        }
    }
}
