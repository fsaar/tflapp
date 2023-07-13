import SwiftUI

struct RetryButton : View {
    let actionHandler : ()-> Void
   
    var body : some View {
        Button(action: {
            actionHandler()
        }, label: {
            HStack {
                Image(systemName:"arrow.clockwise.circle")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width:40)
                    .tint(.tflErrorViewBorder)
                
                Text("TFLRetryButton.retryButtonTitle")
                
                    .font(.headline)
                    .foregroundColor(.tflPrimaryText)
                
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding([.horizontal],40)
            .padding([.vertical],10)
        })
    }
}
