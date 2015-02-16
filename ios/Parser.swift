//
//  Parser.swift
//  ios
//
//  Created by Ehsan Asdar on 2/14/15.
//  Copyright (c) 2015 Ehsan Asdar. All rights reserved.
//

import Foundation

class Parser{
    class func parseAverages(html:String)->[Course]{
        var err : NSError?
        var parser = HTMLParser(html: html, error: &err)
        var html = parser.html
        var metadataTable = html?.findNodeById("finalTablebotLeft1")?.findNodeById("tableHeaderTable")
        var metadataRows = metadataTable?.findChildTags("tr")
        var gradeTable = html?.findNodeById("finalTablebottomRight1")?.findNodeById("tableHeaderTable")
        var gradeRows = gradeTable?.findChildTags("tr")
        var courses:Array<Course>
        courses = []
        var blah:Int? = metadataRows!.count-1
        for i in 1 ... blah!{
            var course = parseCourse(metadataRows![i]
                ,graderow: gradeRows![i])
            courses.append(course)
        }
        return courses
    }
    class func parseCourse(metadatarow:HTMLNode?,graderow:HTMLNode?)->Course{
        var metadataCells = metadatarow?.findChildTags("td")
        var gradeCells = graderow?.findChildTags("td")
        
        var courseID = metadataCells![0].contents
        var teacherCell = metadataCells![2].findChildTag("a")!
        var titleCell = metadataCells![3]
        
        var semesters:Array<Semester> = []
        for i in 0...1{
            var celloffset = i*(5)
            var semestercells:Array<HTMLNode> = []
            for j in 0...2{
                semestercells.append(gradeCells![celloffset+j])
            }
            var examCell = gradeCells![celloffset+3]
            var semAvgCell = gradeCells![celloffset+4]
            semesters.append(parseSemester(semestercells, examcell: examCell,avgcell:semAvgCell,index:i))
        }
        let course = Course(title: titleCell.contents, teacherName: teacherCell.contents, courseId: courseID, semseters: semesters)
        return course
    }
    class func parseSemester(cyclecells:[HTMLNode], examcell:HTMLNode,avgcell:HTMLNode,index:Int)->Semester{
        var cycles:[Cycle] = []
        for i in 0...2{
            cycles.append(parseCycle(cyclecells[i],index:i))
        }
        var examlink = examcell.findChildTag("a")
        var examgrade = GradeValue(fromString: examlink!.contents)
        if let fontTag = examlink?.findChildTag("font"){
            examgrade = GradeValue(fromString: fontTag.contents)
        }
        var semesterlink = avgcell.findChildTag("a")
        var numcompleted = Float(0)
        var tempavg = Float(0)
        for i in 0...2{
            if (cycles[i].average.grade != -1){
                numcompleted++
                tempavg+=cycles[i].average.grade
            }
        }
        if(examgrade.grade != -1){
            numcompleted++
            tempavg+=examgrade.grade
        }
        var semaverage = GradeValue(gradefloat:(tempavg/numcompleted))
        let semesterout = Semester(index: index, average: semaverage, examGrade: examgrade, cycles: cycles)
        return semesterout
    }
    class func parseCycle(cycle:HTMLNode,index:Int)->Cycle{
        var link = cycle.findChildTag("a")
        var average = GradeValue(fromString:link!.contents)
        if let fontTag = link?.findChildTag("font"){
            average = GradeValue(fromString: fontTag.contents)
        }
        let cycle = Cycle(index: index, average: average)
        return cycle
    }
}