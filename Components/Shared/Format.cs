using System.Globalization;

namespace PetShop.Components.Shared;

public static class Format
{
    public static string Vnd(decimal value) =>
        string.Create(CultureInfo.GetCultureInfo("vi-VN"), $"{value:C0}");

    public static string DateTimeVi(DateTime value) =>
        value.ToString("dd/MM/yyyy HH:mm", CultureInfo.GetCultureInfo("vi-VN"));

    public static string DateOnlyVi(DateOnly value) =>
        value.ToString("dd/MM/yyyy", CultureInfo.GetCultureInfo("vi-VN"));
}