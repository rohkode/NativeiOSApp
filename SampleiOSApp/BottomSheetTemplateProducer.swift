//  BottomSheetTemplateProducer.swift
//  SampleiOSApp
//  Created by Rohit Khandka on 18/08/26.

import CleverTapSDK

class BottomSheetTemplateProducer: NSObject, CTTemplateProducer {
    func defineTemplates(_ instanceConfig: CleverTapInstanceConfig) -> Set<CTCustomTemplate> {
        let presenter = BottomSheetPresenter()

        let builder = CTInAppTemplateBuilder()
        builder.setName("bottom_sheet")
        builder.setPresenter(presenter)
        builder.addArgument("title", string: "Default Title")
        builder.addArgument("message", string: "Default message text")
        builder.addArgument("ctaText", string: "Got it")

        return [builder.build()]
    }
}
