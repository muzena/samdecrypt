using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;
using System.Xml;



namespace libEPG_xml2josn
{
    
    class Program
    {
    
        static string sl = "\\";
		static string thisDir = "";
        static void Main(string[] args)
        {
            InitializeComponent();
            bool flag = true;
            StreamReader streamReader=null;
            try
            {
                thisDir = Path.GetDirectoryName(System.Reflection.Assembly.GetAssembly(typeof(Program)).CodeBase).Substring(6);
                if(!File.Exists(thisDir + sl+"config.ini"))
				{
                    sl="/";
					thisDir = Path.GetDirectoryName(System.Reflection.Assembly.GetAssembly(typeof(Program)).CodeBase).Substring(5);
				}
                streamReader = new StreamReader(thisDir + sl+ "config.ini");
                string input = streamReader.ReadToEnd();
                if (streamReader != null)
                {
                    streamReader.Close();
                    streamReader.Dispose();
                }
                Regex regex = new Regex("message:(?<ans>(\\S)+)");
                Match match = regex.Match(input);

                bool.TryParse(match.Groups["ans"].Value, out flag);
            }
            catch (Exception exc)
            {
                if (streamReader != null)
                {
                    streamReader.Close();
                    streamReader.Dispose();
                }
                Console.WriteLine("Error 0: " + exc.Message + "\n" + exc.GetType().ToString());
                //MessageBox.Show(exc.Message + "\nLoad default data", "Settings file error", MessageBoxButtons.OK, MessageBoxIcon.Asterisk);
            }
            xml2josn();
            if (flag)
            {
                Console.WriteLine("Press ESC to stop");
                while (Console.ReadKey(true).Key != ConsoleKey.Escape);
            }
        }
        static void xml2josn()
        {
            
            try
            {
                string str_premiere = "Premiere";
                string str_director = "Director";
                string str_writer = "Writer";
                string str_actors = "Actors";
                string str_star = "★";
                string str_star_empty = "☆";
				string path_guide_xml = thisDir;
				string path_libEPG = thisDir;
                //string thisDir = Path.GetDirectoryName(System.Reflection.Assembly.GetAssembly(typeof(Program)).CodeBase).Substring(6);
                long num = 0L;
                bool bconfig = false;
                bool bzip = false;
                Dictionary<string, string> CatGroupDic = new Dictionary<string, string>();
                Dictionary<string, string> TitleShortDic = new Dictionary<string, string>();
                Dictionary<string, string> CatCreatorViaTitle = new Dictionary<string, string>();
                Dictionary<string, string> CatCreatorViaDescription = new Dictionary<string, string>();
                Dictionary<string, string> DiffOffSetForCH = new Dictionary<string, string>();
                Dictionary<string, string> DiffOffSetForProvider = new Dictionary<string, string>();
                StreamReader streamReader = null;
                try
                {
                    streamReader = new StreamReader(thisDir + sl + "config.ini");
                    string input = streamReader.ReadToEnd();
                    if (streamReader != null)
                    {
                        streamReader.Close();
                        streamReader.Dispose();
                    }
                    Regex regex = new Regex("director:(?<director>(\\S)+)");
                    Match match = regex.Match(input);
                    str_director = match.Groups["director"].Value;
                    regex = new Regex("writer:(?<writer>(\\S)+)");
                    match = regex.Match(input);
                    str_writer = match.Groups["writer"].Value;
                    regex = new Regex("actors:(?<actors>(\\S)+)");
                    match = regex.Match(input);
                    str_actors = match.Groups["actors"].Value;

                    regex = new Regex("cstar:(?<star>(\\S)+)");
                    match = regex.Match(input);
                    str_star = match.Groups["star"].Value;

                    regex = new Regex("cstarempty:(?<star>(\\S)+)");
                    match = regex.Match(input);
                    str_star_empty = match.Groups["star"].Value;

                    regex = new Regex("premiere:(?<premiere>(\\S)+)");
                    match = regex.Match(input);
                    str_premiere = match.Groups["premiere"].Value;

                    regex = new Regex("guide.xml path:\"(?<guide>([^\"])+)",RegexOptions.IgnoreCase);
                    match = regex.Match(input);
                    string str_guide_xml_temp = match.Groups["guide"].Value;
                    if (str_guide_xml_temp != string.Empty)
                        path_guide_xml = str_guide_xml_temp;

                    regex = new Regex("libEPG.config path:\"(?<libEPG>([^\"])+)", RegexOptions.IgnoreCase);
                    match = regex.Match(input);
                    string str_libEPG_temp = match.Groups["libEPG"].Value;
                    if (str_libEPG_temp != string.Empty)
                        path_libEPG = str_libEPG_temp;

                    regex = new Regex("zip:(?<ans>(\\S)+)");
                    match = regex.Match(input);

                    bool.TryParse(match.Groups["ans"].Value, out bzip);

                    bconfig = true;

                    CatGroupDic = Util.GetParamDictionary(input, "categories group ");
                    TitleShortDic = Util.GetParamDictionary(input, "title short ");
                    CatCreatorViaTitle = Util.GetParamDictionary(input, "user categorie via title ");
                    CatCreatorViaDescription = Util.GetParamDictionary(input, "user categorie via description ");
                    DiffOffSetForCH = Util.GetParamDictionary(input, "difference of offset for channels ");
                    DiffOffSetForProvider = Util.GetParamDictionary(input, "difference of offset for provider ");
                    
                }
                catch (Exception exc)
                {
                    if (streamReader != null)
                    {
                        streamReader.Close();
                        streamReader.Dispose();
                    }
                    Console.WriteLine(exc.Message + "\nconfig.ini load default params");
                    //MessageBox.Show(exc.Message + "\nLoad default data", "Settings file error", MessageBoxButtons.OK, MessageBoxIcon.Asterisk);
                }
                if (bconfig)
                    Console.WriteLine("Params from config.ini file was loaded");

                StreamWriter streamWriter = new StreamWriter(path_libEPG + sl + "libEPG.config", false);
                XmlDocument xmlDocument = new XmlDocument();
               try
                {
                    Console.WriteLine("File reading:  " + path_guide_xml + sl + "guide.xml");
                    xmlDocument.Load(path_guide_xml + sl + "guide.xml");
                    Console.WriteLine("The guide.xml file was read");
                    Console.WriteLine("Creating a libEPG.config");
                    uint num2 = 1u;
                    JavaScriptSerializer javaScriptSerializer = new JavaScriptSerializer();
                    XmlNodeList elementsByTagName = xmlDocument.DocumentElement.GetElementsByTagName("channel");
                    Dictionary<string, string[]> dictionary = new Dictionary<string, string[]>();
                    foreach (XmlNode xmlNode in elementsByTagName)
                    {
                        string value = xmlNode.Attributes["id"].Value;
                        string dispName = string.Empty;
                        string url = string.Empty;
                        foreach (XmlNode xmlNode_ in xmlNode.ChildNodes)
                        {
                            string nameNode = xmlNode_.Name;
                            switch (nameNode)
                            {
                                case "display-name":
                                    dispName = xmlNode_.InnerText;
                                    break;
                                case "url":
                                    url = xmlNode_.InnerText;
                                    break;
                            }
                        }
                        
                        dictionary.Add(value, new string [] {dispName,url});
                    }
                    XmlNodeList elementsByTagName2 = xmlDocument.DocumentElement.GetElementsByTagName("programme");
                    string text = string.Empty;
                    string text2 = string.Empty;
                    string text3 = string.Empty;
                    string text4 = string.Empty;
                    string text5 = string.Empty;
                    string description = string.Empty;
                    string title = string.Empty;
                    string text8 = string.Empty;
                    string subtitle = string.Empty;
                    string text10 = string.Empty;
                    string text11 = string.Empty;
                    string country = string.Empty;
                    string category = string.Empty;
                    string text13 = string.Empty;
                    string text14 = string.Empty;
                    string actors = string.Empty;
                    string premiere = string.Empty;
                    
                    List<Channel> list = new List<Channel>();
                    Channel channel = new Channel(null);
                    streamWriter.WriteLine("{");
                    bool flag2 = true;
                    string value2;
                    foreach (XmlNode xmlNode2 in elementsByTagName2)
                    {
                        text2 = dictionary[xmlNode2.Attributes["channel"].Value][0];
                        if (text != string.Empty)
                        {
                            if (text != text2)
                            {
                                text = text2;
                                list.Add(channel);
                                if (!flag2)
                                {
                                    streamWriter.WriteLine(",");
                                }
                                else
                                {
                                    flag2 = false;
                                }
                                streamWriter.WriteLine("\"" + channel.Name + "\":");
                                javaScriptSerializer = new JavaScriptSerializer();
                                value2 = javaScriptSerializer.Serialize(channel.Programs);
                                streamWriter.WriteLine(value2);
                                channel = new Channel(text);
                            }
                        }
                        else
                        {
                            text = text2;
                            channel = new Channel(text);
                        }
                        Util.Offset offsetFromConfigCh = null;
                        Util.Offset offsetFromConfigProvider = null;
                        if(DiffOffSetForProvider.ContainsKey(dictionary[xmlNode2.Attributes["channel"].Value][1]))
                        {
                            offsetFromConfigProvider = new Util.Offset(DiffOffSetForProvider[dictionary[xmlNode2.Attributes["channel"].Value][1]]);
                        }
                        
                        string diffOffset = null;
                        DiffOffSetForCH.TryGetValue(channel.Name, out diffOffset);
                        if (diffOffset != null)
                            offsetFromConfigCh = new Util.Offset(diffOffset);

                        text3 = xmlNode2.Attributes["start"].Value;

                        foreach (XmlNode xmlNode3 in xmlNode2.ChildNodes)
                        {
                            string name = xmlNode3.Name;
                            switch (name)
                            {
                                case "title":
                                    if (title == string.Empty)
                                    {
                                        title = xmlNode3.InnerText;
                                        foreach (KeyValuePair<string, string> entry in CatCreatorViaTitle)
                                        {
                                            if (Regex.IsMatch(title, entry.Key.ToLower(), RegexOptions.IgnoreCase))
                                            {
                                                category = entry.Value + ",";
                                                break;
                                            }
                                        }
                                        foreach (KeyValuePair<string, string> entry in TitleShortDic)
                                        {
                                            if (Regex.IsMatch(title, entry.Key.ToLower(), RegexOptions.IgnoreCase))
                                            {
                                                title = Regex.Replace(title, entry.Key.ToLower(),entry.Value, RegexOptions.IgnoreCase);
                                                break;
                                            }
                                        }


                                    }
                                    else if (text8 == string.Empty)
                                    {
                                        text8 = xmlNode3.InnerText;
                                    }
                                    break;
                                case "sub-title":
                                    if (subtitle == string.Empty)
                                    {
                                        subtitle = xmlNode3.InnerText;
                                    }
                                    break;
                                case "desc":
                                    if (description == string.Empty)
                                    {
                                        description = xmlNode3.InnerText;
                                        foreach (KeyValuePair<string, string> entry in CatCreatorViaDescription)
                                        {
                                            if (Regex.IsMatch(description, entry.Key.ToLower(), RegexOptions.IgnoreCase))
                                            {
                                                category = entry.Value + ",";
                                                break;
                                            }
                                        }
                                    }
                                    break;
                                case "category":
                                    if (category != string.Empty)
                                    {
                                        category = category + " " + xmlNode3.InnerText;
                                    }
                                    else
                                    {
                                        category = xmlNode3.InnerText + ",";
                                        foreach (KeyValuePair<string, string> entry in CatGroupDic)
                                        {
                                            if (entry.Key.ToLower() == xmlNode3.InnerText.ToLower())
                                            {
                                                category = entry.Value + ",";
                                                break;
                                            }
                                        }
                                        
                                    }
                                    break;
                                case "episode-num":
                                    if (text10 == string.Empty)
                                    {
                                        text10 = xmlNode3.InnerText;
                                    }
                                    break;
                                case "date":
                                    if (text11 == string.Empty)
                                    {
                                        text11 = xmlNode3.InnerText;
                                    }
                                    break;
                                case "country":
                                    if (country == string.Empty)
                                    {
                                        country = xmlNode3.InnerText;
                                    }
                                    break;
                                case "rating":
                                    foreach (XmlNode xmlNode4 in xmlNode3)
                                    {
                                        if (xmlNode4.Name == "value")
                                        {
                                            if (text5 == string.Empty)
                                            {
                                                text5 = xmlNode4.InnerText;
                                                int num3;
                                                if (!int.TryParse(text5[0].ToString(), out num3))
                                                {
                                                    text5 = "";
                                                }
                                                break;
                                            }
                                        }
                                    }
                                    break;
                                case "credits":
                                    foreach (XmlNode xmlNode4 in xmlNode3)
                                    {
                                        name = xmlNode4.Name;
                                        if (name != null)
                                        {
                                            if (!(name == "director"))
                                            {
                                                if (name == "writer")
                                                {
                                                    text14 = text14 + xmlNode4.InnerText + ", ";
                                                }
                                            }
                                            else
                                            {
                                                text13 = text13 + xmlNode4.InnerText + ", ";
                                            }
                                            if (name == "actor")
                                            {
                                                string act_tmp = xmlNode4.InnerText.Replace("\r\n", "");
                                                act_tmp = act_tmp.Replace("\r", "");
                                                act_tmp = act_tmp.Replace("\r\n", "");
                                                act_tmp = act_tmp.Replace("\t", "");

                                                RegexOptions options = RegexOptions.None;
                                                Regex regex = new Regex(@"[ ]{2,}", options);
                                                act_tmp = regex.Replace(act_tmp, @" ");

                                                actors = actors + act_tmp + ", ";
                                            }
                                        }
                                    }
                                    break;
                                case "star-rating":
                                    foreach (XmlNode xmlNode4 in xmlNode3)
                                    {
                                        if (xmlNode4.Name == "value")
                                        {
                                            if (text4 == string.Empty)
                                            {
                                                text4 = xmlNode4.InnerText;
                                            }
                                            break;
                                        }
                                    }
                                    break;
                                case "premiere":
                                        premiere = str_premiere;
                                    break;
                            }
                        }
                        string s = text3.Substring(0, 14);
                        //string timeZone_Offset = text3.Substring(15, 1);
                        //int timeZone_Offset_hour = int.Parse(text3.Substring(16, 2));
                        //int timeZone_Offset_minute = int.Parse(text3.Substring(18, 2));
                        //TimeSpan offsetFromGuide = new TimeSpan(timeZone_Offset_hour, timeZone_Offset_minute, 0);
                        
                        Util.Offset offsetFromGuide = new Util.Offset(text3.Substring(15, 5));
                        
                        description = description.TrimEnd(new char[]
					{
						'(',
						'n',
						')'
					}) + '.';
                        string text16 = string.Empty;

                        if (category != string.Empty)
                        {
                            text16 = text16 + Util.UppercaseFirst(category);
                        }
                        if (text16 != string.Empty)
                        {
                            if (text16.Substring(text16.Length - 1, 1) == ",")
                            {
                                text16 = text16.Substring(0, text16.Length - 1);
                            }
                            text16 += " | ";
                        }
                        if (country != string.Empty)
                        {
                            text16 = text16 + country + " | ";
                        }
                        if (text11 != string.Empty)
                        {
                            text16 = text16 + text11 + " | ";
                        }
                        if (text10 != string.Empty && text10 != "0")
                        {
                            text16 = text16 + text10 + " | ";
                        }
                        if (text5 != string.Empty)
                        {
                            text16 = text16 + text5 + " | ";
                        }
                        if (text4 != string.Empty)
                        {
                           List<double> stars = Util.GetNumberFromString(text4);
                           if (stars.Count == 0)
                           {
                               text16 = text16 + text4 + " | ";
                           }
                           else
                           {
                               int starempty = 0;
                               double star = Math.Round(stars[0]);
                               if (stars.Count > 1)
                               {
                                   starempty = (int)Math.Round(stars[1]) - (int)Math.Round(stars[0]);
                               }
                               text4 = Util.Star(star, str_star) + Util.StarEmpty(starempty, str_star_empty);
                               text16 = text16 + text4 + " | ";
                           }
                        }
                        if (premiere != string.Empty)
                        {
                            text16 = text16 + premiere + " | ";
                        }
                        
                        if (text16 != string.Empty)
                        {
                            if (text16.Substring(text16.Length - 3, 3) == " | ")
                            {
                                text16 = text16.Substring(0, text16.Length - 3);
                            }
                            text16 += "\t\r\n";
                        }
                        if (text8 != string.Empty)
                        {
                            text16 = text16 + "(" + text8 + ")";
                            if (subtitle != string.Empty)
                            {
                                text16 += ", ";
                            }
                            else
                            {
                                text16 += "\r\n";
                            }
                        }
                        if (subtitle != string.Empty)
                        {
                            text16 += subtitle + "\r\n";
                        }
                        if (description == ".")
                        {
                            description = text16;
                        }
                        else
                        {
                            description = text16 + description;
                        }
                        if (text14 != string.Empty)
                        {
                            if (text14.Substring(text14.Length - 2, 2) == ", ")
                            {
                                text14 = text14.Substring(0, text14.Length - 2);
                            }
                            if (description != string.Empty)
                            {
                                description = description + "\r\n" + str_writer + ": " + text14 + ". ";
                            }
                            else
                            {
                                description = text14;
                            }
                        }
                        if (text13 != string.Empty)
                        {
                            if (text13.Substring(text13.Length - 2, 2) == ", ")
                            {
                                text13 = text13.Substring(0, text13.Length - 2);
                            }
                            if (description != string.Empty)
                            {
                                description = description + "\r\n" + str_director + ": " + text13 + ". ";
                            }
                            else
                            {
                                description = text13;
                            }
                        }
                        if (actors != string.Empty)
                        {
                            if (actors.Substring(actors.Length - 2, 2) == ", ")
                            {
                                actors = actors.Substring(0, actors.Length - 2);
                            }
                            if (description != string.Empty)
                            {
                                description = description + "\r\n" + str_actors + ": " + actors + ". ";
                            }
                            else
                            {
                                description = actors;
                            }
                        }
                        DateTime dateTime = DateTime.ParseExact(s, "yyyyMMddHHmmss", CultureInfo.CurrentCulture);
						//TimeSpan timeSpan;// = new TimeSpan(0, 0, 0);
                        //if (!TimeZoneInfo.Local.IsDaylightSavingTime(dateTime))
                        //{
                        //    timeSpan = new TimeSpan(1, 0, 0);
                        //}
                        //TimeSpan t = TimeSpan.ParseExact(input2, "HHmmss", CultureInfo.InvariantCulture);
                        
                        //TimeSpan.TryParseExact(input2,"HHmm", CultureInfo.InvariantCulture, out t);
                       // TimeZone currentTimeZone = TimeZone.CurrentTimeZone;
                       // TimeSpan utcOffset = currentTimeZone.GetUtcOffset(DateTime.Now);
                       // TimeSpan t2 = utcOffset - t;
                       //double aaa=0;
                       // if (t2.TotalSeconds != 0)
                       //     aaa = t2.TotalSeconds;

                        int time = (int)(dateTime - new DateTime(1970, 1, 1) - offsetFromGuide.Value).TotalSeconds;
                        if (!offsetFromGuide.Plus)
                            time = (int)(dateTime - new DateTime(1970, 1, 1) + offsetFromGuide.Value).TotalSeconds;
                        if (offsetFromConfigProvider != null)
                        {

                            if (offsetFromConfigProvider.Plus)
                                time = time + (int)offsetFromConfigProvider.Value.TotalSeconds;
                            else
                                time = time - (int)offsetFromConfigProvider.Value.TotalSeconds;
                        }
                        if (offsetFromConfigCh != null)
                        {
                            
                            if (offsetFromConfigCh.Plus)
                                time = time + (int)offsetFromConfigCh.Value.TotalSeconds;
                            else
                                time = time - (int)offsetFromConfigCh.Value.TotalSeconds;
                        }

                        if (num2++ > 65535)
                            throw new Exception("eventId must be less than 65535!!");
                        Prog item = new Prog(title, description, time, num2);
                        num += 1L;
                        channel.Programs.Add(item);
                        description = string.Empty;
                        text10 = string.Empty;
                        title = string.Empty;
                        text8 = string.Empty;
                        subtitle = string.Empty;
                        text11 = string.Empty;
                        country = string.Empty;
                        category = string.Empty;
                        text3 = string.Empty;
                        text4 = string.Empty;
                        text5 = string.Empty;
                        text13 = string.Empty;
                        text14 = string.Empty;
                        actors = string.Empty;
                        premiere = string.Empty;
                    }
                    list.Add(channel);
                    streamWriter.WriteLine(",");
                    streamWriter.WriteLine("\"" + channel.Name + "\":");
                    javaScriptSerializer = new JavaScriptSerializer();
                    value2 = javaScriptSerializer.Serialize(channel.Programs);
                    streamWriter.WriteLine(value2);
                    streamWriter.WriteLine("}");
                    streamWriter.Close();
                    streamWriter.Dispose();
                    Console.WriteLine("The libEPG.config file was created");
                    string arg_C00_0 = "Program TV save as: libEPG.config\r\nChannels: ";
                    int count = list.Count;
                    string text17 = arg_C00_0 + count.ToString() + "\r\nEntries: " + (num2 - 1u).ToString();
                    Console.WriteLine(text17);
                    if (bzip)
                    {

                        string zipPath = path_libEPG + sl + "libEPG.zip";
                        string newFile = path_libEPG + sl + "libEPG.config";
                        try
                        {
                            if (File.Exists(zipPath))
                            {
                                File.Delete(zipPath);
                            }
                            using (ZipArchive archive = ZipFile.Open(zipPath, ZipArchiveMode.Create))
                            {
                                archive.CreateEntryFromFile(newFile, "libEPG.config", CompressionLevel.Optimal);

                                Console.WriteLine("The libEPG.config file was archived to libEPG.zip file");
                            }
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine("Error ZipArchive: " + ex.Message + "\n" + ex.GetType());
                        }

                    }    
                        //MessageBox.Show(text17, "Info", MessageBoxButtons.OK, MessageBoxIcon.Asterisk, MessageBoxDefaultButton.Button1, MessageBoxOptions.DefaultDesktopOnly);
                    
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error 1: " + ex.Message + "\n" + ex.GetType().ToString());
                    //MessageBox.Show(ex.Message + "\n" + ex.GetType().ToString(), "Error 1", MessageBoxButtons.OK, MessageBoxIcon.Hand);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error 2: " + ex.Message + "\n" + ex.GetType());
                //MessageBox.Show(ex.Message, "Error 2", MessageBoxButtons.OK, MessageBoxIcon.Hand);
            }

        }
        static void InitializeComponent()
        {
           Console.Title = "libEPG_xml2josn";
           Console.Clear();
        }
        
    }
}
