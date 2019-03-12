using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Text.RegularExpressions;

namespace libEPG_xml2josn
{
    static class Util
    {
       public static string UppercaseFirst(string s)
        {
            // Check for empty string.
            if (string.IsNullOrEmpty(s))
            {
                return string.Empty;
            }
            // Return char and concat substring.
            return char.ToUpper(s[0]) + s.Substring(1);
        }
       public static string StarEmpty(double l, string star)
       {
           string s = string.Empty;
           for (int i = 0; i < l; i++)
               s += star;
           return s;
       }
       public static string Star(double l, string star)
       {
           string s = string.Empty;
           for (int i = 0; i < l; i++)
               s += star;
           return s;
       }
       public static List<double> GetNumberFromString(string str)
       {
           str = str.Replace("/", "per");
           System.Text.RegularExpressions.MatchCollection matches = System.Text.RegularExpressions.Regex.Matches(str, @".*?([-]{0,1} *(\d+.\d+)|\d+)");

           List<double> nums = new List<double>();

           foreach (System.Text.RegularExpressions.Match match in matches)
           {

               string value = match.Groups[1].Value;

               value = value.Replace(" ", "");

               double num1 = -1;
               double.TryParse(value, out num1);
               if (num1 == 0)
               {
                   System.Globalization.NumberStyles style = System.Globalization.NumberStyles.Number | System.Globalization.NumberStyles.AllowCurrencySymbol;
                   System.Globalization.CultureInfo culture = System.Globalization.CultureInfo.CreateSpecificCulture("en-GB");
                   double.TryParse(value, style, culture, out num1);
               }
               nums.Add(num1);

           }
           return nums;
       }

       public static Dictionary<string, string> GetParamDictionary(string input, string sPattern)
       {
           Dictionary<string, string> Dic = new Dictionary<string, string>();
           int CatID = 0;
           while (true)
           {
               Regex regex = new Regex(sPattern + CatID++.ToString() + ":\"(?<cGroup>([^\"])+)", RegexOptions.IgnoreCase);
               Match match = regex.Match(input);
               if (match.Groups["cGroup"].Length < 1)
                   break;
               string[] catGroups = match.Groups["cGroup"].Value.Split(new char[] { ';' });
               if (catGroups.Length > 1)
               {
                   for (int i = 1; i < catGroups.Length; i++)
                   {
                       if (!Dic.ContainsKey(catGroups[i]))
                       {
                           Dic.Add(catGroups[i], catGroups[0]);
                       }
                   }

               }
           }
           return Dic;
       }

       public class Offset
       {
           public TimeSpan Value { get; private set; }
           public bool Plus { get; private set; }

           public Offset(string input)
           {
               this.CreateOffsetFromString(input);
           }
           private void CreateOffsetFromString(string input)
           {
               try
               {
                   this.Plus = true;
                   if (input.Substring(0, 1) == "-")
                       this.Plus = false;
                   int timeZone_Offset_hour = int.Parse(input.Substring(1, 2));
                   int timeZone_Offset_minute = int.Parse(input.Substring(3, 2));
                   this.Value = new TimeSpan(timeZone_Offset_hour, timeZone_Offset_minute, 0);
               }
               catch (Exception ex)
               {
                   Console.WriteLine("Error CreateOffsetFromString: " + ex.Message + "\n" + ex.GetType());
               }


           }
       }

    }
}
