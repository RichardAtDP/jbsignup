import FluentProvider
import LeafProvider
import AuthProvider
import MySQLProvider
import SendGrid
import SMTP

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        
         addConfigurable(mail: SendGrid.init, name: "sendgrid")
         
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)

    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Post.self)
        preparations.append(dancer.self)
        preparations.append(family.self)
        preparations.append(lesson.self)
        preparations.append(counter.self)
    }
}
