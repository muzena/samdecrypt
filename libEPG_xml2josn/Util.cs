using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
    }
}
