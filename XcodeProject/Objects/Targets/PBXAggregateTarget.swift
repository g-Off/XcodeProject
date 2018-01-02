//
//  PBXAggregateTarget.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-23.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXAggregateTarget: PBXTarget {
	public override func addBuildPhase<T: PBXBuildPhase>() -> T? {
		if T.self == PBXCopyFilesBuildPhase.self || T.self == PBXShellScriptBuildPhase.self {
			return T(globalID: PBXObject.ID())
		}
		return nil
	}
}
