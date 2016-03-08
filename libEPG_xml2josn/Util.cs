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
    }
}
