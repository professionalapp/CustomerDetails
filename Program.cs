using CustomerDetails.Models;
using Google.Cloud.Firestore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddControllers();

// Configure Firebase Firestore
// IMPORTANT: Replace with the actual path to your service account key file
string firebaseConfigPath = Path.Combine(builder.Environment.ContentRootPath, "employee-services-60fa4-firebase-adminsdk-o405k-d21a9b72c4.json");
Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", firebaseConfigPath);

// IMPORTANT: Replace "YOUR_PROJECT_ID" with your actual Firebase project ID
FirestoreDb firestoreDb = FirestoreDb.Create("employee-services-60fa4");
builder.Services.AddSingleton(firestoreDb);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();
app.MapControllers();

app.Run();
