import SwiftUI

struct NoContentAvailableView<Button: View> : View {
    @ScaledMetric(relativeTo:.headline) var imageWidth = 40
    let title : String
    let description : String
    let button : Button?
    init(title : String = "", description : String = "",@ViewBuilder button: () -> Button?)  {
        self.title = title
        self.description = description
        self.button = button()
    }
    
    var body : some View {
        VStack(spacing:10) {
            
            Text(LocalizedStringKey(title))
                .textCase(.uppercase)
                .font(.title)
                .foregroundColor(.tflPrimaryText)
                .isHidden(title.isEmpty)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            Text(LocalizedStringKey(description))
                .font(.body)
                .foregroundColor(.tflPrimaryText)
                .isHidden(description.isEmpty)
            
            button
            
        }
        .padding(30)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        Spacer()
        
    }
}
